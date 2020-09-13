#!/usr/bin/env python3

#==== BCLS2 to OBJ Converter ====
# MIT License
# Copyright (c) 2020 EddyK28


#BCLS2 file
#  SIR0 Stuff: 16B
#  Header: 36B
#  Head List (only ever 1 item?)
#  Face Group List
#  Floor faces
#  Wall faces
#  Vertex Coords
#  Face Group sublists
#  "hitdata" literal
#  SIR0 pointers (points to items marked with *)


#Header (36B)
#  Ukn (always 0x10001000
#  Head List Size (always 1?)
#  Head List Ptr *
#  Floor List Size
#  Floor List Ptr  (int 6tuples)*
#  Wall List Size
#  Wall List Ptr  (int triples)*
#  Coord List Size
#  Coord List Ptr  (float triples)*


#Head List Item (40B)
#  'hitdata' ptr *
#  charPos divisor (always 1)
#  posX subtrahend (for face lookup, Always 0xFFFFFFxx)
#  posY subtrahend (for face lookup, Always 0xFFFFFFxx)
#  Face Group grid Y size (Always 0x000000xx)
#  Face Group grid X size (Always 0x000000xx)
#  Face Group List Size
#  Face Group List Ptr *
#  Ukn (always 1)
#  Ukn (always 1)


#Face Group List Item (16B)
#  Floor Sublist Size
#  Floor Sublist Ptr *
#  Wall Sublist Size
#  Wall Sublist Ptr *
#
#   item 0, Floor Sublist Ptr usually == Floor List Ptr, Floor Sublist Size == 0
#   last item pointers usually == 'hitdata' ptr


#Note: BCLS2 vertex numbers are 0 indexed, while obj are 1 indexed


import os
import sys
from struct import pack, unpack


def read_float(f):
	return unpack('<f', f.read(4))[0]

def read_uint32(f):
	return unpack('<I', f.read(4))[0]

def read_int32(f):
	return unpack('<i', f.read(4))[0]
	
def read_4bytes(f):
	return ''.join('{:02x} '.format(x) for x in f.read(4))
	
	
	
if len(sys.argv) != 3 and len(sys.argv) != 4:
	print('usage: ' + os.path.basename(sys.argv[0]) + ' [pf] COLLISION.BCLS2 OUTPUT.OBJ')
	print('  p = print extra info, f = write faces from face group list')
	print('  NOTE: open/import obj without flipping ZY-axis')
	exit(0)

bPrintInfo = False
bFaceWrite = False
iarg=1

if len(sys.argv) == 4:
	iarg=2
	bPrintInfo = 'p' in sys.argv[1]
	bFaceWrite = 'f' in sys.argv[1]

with open(sys.argv[iarg], 'rb') as fIn:
	with open(sys.argv[iarg+1], 'w') as fOut:
		fOut.write("# Created by bcls2obj from "+os.path.basename(sys.argv[1])+"\n")
		fOut.write("# May be buggy/missing faces, don't expect miracles\n")
		fOut.write("# NOTE: open/import without flipping ZY-axis\n\n")
		
		fIn.seek(0x10)
		
		#unknown header start value
		headUkn = fIn.read(4)
		
		#Read size and pointer for that strange 1 item list
		listHeadSize = read_uint32(fIn)
		listHeadPtr = read_uint32(fIn)
		
		#Read size and pointer for floor face list
		listFloorSize = read_uint32(fIn)
		listFloorPtr = read_uint32(fIn)
		
		#Read size and pointer for wall face list
		listWallSize = read_uint32(fIn)
		listWallPtr = read_uint32(fIn)
		
		#Read size and pointer for vertex coord list
		listCoordSize = read_uint32(fIn)
		listCoordPtr = read_uint32(fIn)
		
		
		#Write and test the header start value
		fOut.write("#Unknown header start value: {:s}\n".format(''.join('{:02x} '.format(x) for x in headUkn)))
		if headUkn != b"\x00\x10\x00\x10":
			fOut.write("#  WARNING: this should be 00 10 00 10\n")
		fOut.write("\n")
		
		#Write out the header list thing
		fIn.seek(listHeadPtr)
		fOut.write("#Unknown header items ({:d} @ {:08x})\n".format(listHeadSize,listHeadPtr))
		fOut.write("# 'hitdata' ptr    pos div      xpos subt     ypos subt       gridY         gridX      GrpLst Size   GrpLst Ptr        Ukn           Ukn\n")
		for x in range(0, listHeadSize):
			fOut.write("#  ")
			for y in range (0,10):
				fOut.write(read_4bytes(fIn)+"  ")
			fOut.write("\n")
		fOut.write("#  GrpLst Info at Bottom\n")
			
		#Does head list have only 1 entry?
		if listHeadSize > 1:
			fOut.write("#WARNING: Header list should only have one item. Something's wrong here.\n")
		fOut.write("\n")
		

		#Read in face group list 
		fIn.seek(listHeadPtr+4)
		groupData = unpack('<5i', fIn.read(20))
		listGroupSize = read_uint32(fIn)
		listGroupPtr = read_uint32(fIn)
		listGroup = []
		
		fIn.seek(listGroupPtr)
		for x in range(0, listGroupSize):
			listGroup.append([])
			for y in range (0,4):
				listGroup[-1].append(read_uint32(fIn))
		
		
		#Run some random tests
		
		#Does ukn list point to floor face list?
		if (listGroup[0][1] != listFloorPtr):
			fOut.write("#WARNING: Ukn entry 0 does not point ({:08x}) to floor face list ({:08x}) like usual\n".format(listGroup[0][1], listFloorPtr,))
			if listGroup[0][0] == 0:
				fOut.write('#  and number before is 0\n')
		elif listGroup[0][0] != 0:
			fOut.write("#WARNING: Ukn entry 0 points to to floor face list, but starts with non-zero ({:08x})\n".format(listGroup[0][0]))
		
		#Does ukn list point to that list at the end of the file?
		if (listGroup[0][3] != listCoordSize*12 + listCoordPtr):
			fOut.write('#WARNING: Ukn entry 0 does not point ({:08x}) to unmarked list ({:08x}) like it should\n'.format(listGroup[0][3], listCoordSize*12 + listCoordPtr))
		
		#Does last ukn3 entry point to "hitdata"?
		fIn.seek(listGroup[-1][-1])
		tmp = fIn.read(8)
		if tmp != b"hitdata\0":
			fOut.write('#WARNING: Ukn list last entry does not point to "hitdata"\n')
			
		#Are Ukn list's pointers strictly increasing?
		tmp = 0;
		for idx, set in enumerate(listGroup):
			if set[1] < tmp:
				fOut.write("#WARNING: Ukn list not strictly increasing (entry {:d} < {:d})\n".format(idx,idx-1))
			if set[3] < set[1]:
				fOut.write("#WARNING: Ukn list not strictly increasing (entry {:d} out of oder)\n".format(idx))
			tmp = set[3]
		fOut.write("\n")
		

		
		#Print some unknowns and things if desired
		if bPrintInfo:
			#get max unknown value (actually group face index)
			tmp = 0
			fIn.seek(listCoordSize*12 + listCoordPtr)
			while fIn.tell() < listGroup[-1][-1]:
				tmp = max(tmp,read_uint32(fIn))
				
			#print file name
			print(os.path.basename(sys.argv[iarg]))
			
			#print out header list thing
			fIn.seek(listHeadPtr)
			print(" 'hitdata' ptr    pos div      xpos subt     ypos subt       gridY         gridX      GrpLst Size   GrpLst Ptr        Ukn           Ukn")
			print(end="  ")
			for y in range (0,10):
				print(read_4bytes(fIn), end="  ")
			print("\n")
			
			#print some other things
			print("  {:d} 0x{:08x}, 0x{:08x} (UknList0, FloorListPtr)".format(listGroup[0][0],listGroup[0][1],listFloorPtr))
			print("  Ukn Count:",(listGroup[-1][-1]-(listCoordSize*12 + listCoordPtr))/4)
			print("  Vert Count:",listCoordSize)
			print("  Wall Count:",listWallSize)
			print("  Floor Count:",listFloorSize)
			print("  Max Ukn value:",tmp+1,end="")
			if tmp+1 == listWallSize:
				print(" (matches wall face count)")
			else:
				print(" (matches floor face count)")
			print("\n")
		
		#Write out vertices
		fIn.seek(listCoordPtr)
		fOut.write("# {:d} Vertices from 0x{:08x}\n".format(listCoordSize,listCoordPtr))
		for x in range(0, listCoordSize):
			fOut.write("v {:f} {:f} {:f}\n".format(read_float(fIn),read_float(fIn),read_float(fIn)))
		fOut.write("\n")
		
		#mesh will always be named "collision"
		fOut.write("g collision\n")
		
		#Write out the floor faces (last 3 of 6 values unknown)
		floorFaces = [] ###
		fIn.seek(listFloorPtr)
		fOut.write("# {:d} Floor Faces from 0x{:08x} (each followed by its unknowns)\n".format(listFloorSize,listFloorPtr))
		for x in range(0, listFloorSize):
			floorFaces.append([read_uint32(fIn)+1,read_uint32(fIn)+1,read_uint32(fIn)+1]) ###
			fOut.write("f {:d} {:d} {:d}\n".format(floorFaces[-1][0],floorFaces[-1][1],floorFaces[-1][2])) ###
			###fOut.write("f {:d} {:d} {:d}\n".format(read_uint32(fIn)+1,read_uint32(fIn)+1,read_uint32(fIn)+1))
			fOut.write("# {:s} {:s} {:s}\n".format(read_4bytes(fIn),read_4bytes(fIn),read_4bytes(fIn)))	#ukn values
		fOut.write("\n")
		
		#Write out the wall faces
		wallFaces = [] ###
		fIn.seek(listWallPtr)
		fOut.write("# {:d} Wall Faces from 0x{:08x}\n".format(listWallSize,listWallPtr))
		for x in range(0, listWallSize):
			wallFaces.append([read_uint32(fIn)+1,read_uint32(fIn)+1,read_uint32(fIn)+1]) ###
			fOut.write("f {:d} {:d} {:d}\n".format(wallFaces[-1][0],wallFaces[-1][1],wallFaces[-1][2])) ###
			###fOut.write("f {:d} {:d} {:d}\n".format(read_uint32(fIn)+1,read_uint32(fIn)+1,read_uint32(fIn)+1))
		fOut.write("\n")
		
		
		#Write out face groups 
		fOut.write("#Face Groups (F = Floor, W = Wall)\n")
		for idx, set in enumerate(listGroup):
			fOut.write("#{:4d} {:08x}(F {:d},{:d}):".format(set[0],set[1],idx%groupData[4],int(idx/groupData[4])))
			if set[0] > 0:
				fIn.seek(set[1])
				for x in range(0,set[0]):
					fOut.write(" {:d}".format(read_uint32(fIn)))
					
				if bFaceWrite:
					###fOut.write("\ng 0x{:08x}\nl".format(set[1]))
					fOut.write("\ng F{:d},{:d}\n".format(idx%groupData[4],int(idx/groupData[4])))###
					fIn.seek(set[1])
					for x in range(0,set[0]):
						face = floorFaces[read_uint32(fIn)]###
						fOut.write("f {:d} {:d} {:d}\n".format(face[0],face[1],face[2]))###
						###fOut.write(" {:d}".format(read_uint32(fIn)+1))
					
				fOut.write("\n")
			else:
				fOut.write(' empty\n')
			
			
			fOut.write("#{:4d} {:08x}(W {:d},{:d}):".format(set[2],set[3],idx%groupData[4],int(idx/groupData[4])))
			if set[2] > 0:
				fIn.seek(set[3])
				for x in range(0,set[2]):
					fOut.write(" {:d}".format(read_uint32(fIn)))
					
				if bFaceWrite:
					###fOut.write("\ng 0x{:08x}\nl".format(set[3]))
					fOut.write("\ng W{:d},{:d}\n".format(idx%groupData[4],int(idx/groupData[4])))###
					fIn.seek(set[3])
					for x in range(0,set[2]):
						face = wallFaces[read_uint32(fIn)]###
						fOut.write("f {:d} {:d} {:d}\n".format(face[0],face[1],face[2]))###
						###fOut.write(" {:d}".format(read_uint32(fIn)+1))
					
				fOut.write("\n")
			else:
				fOut.write(' empty\n')
			
