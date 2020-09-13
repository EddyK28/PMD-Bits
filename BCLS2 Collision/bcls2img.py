#!/usr/bin/env python3

#==== BCLS2 Face Lookup Test / Heightmap Render ====
# MIT License
# Copyright (c) 2020 EddyK28


from PIL import Image
import os
import sys
import math
from struct import pack, unpack

X = 0
Y = 1
Z = 2

def read_uint32(f):
	return unpack('<I', f.read(4))[0]

def vec2Sub(a, b):
	return [a[X] - b[X], a[Y] - b[Y]]

def vec2Ukn(a, b):
	return (a[X] * b[Y]) - (a[Y] * b[X]);

	
#Convert character position to face group coords
#  A face group is all the faces covered by one grid cell
#  See collision_tw00_home04 example here: https://i.imgur.com/FEog6kE.png
def bclsGetFaceGroup(charPos, headList):
	return [ math.floor(charPos[X] / headList[1]) - headList[2] , math.floor(charPos[Y] / headList[1]) - headList[3] ]

#BCLS2 Floor Face Lookup Algorithm
#Get the collision face index under the given character position
def bclsGetFloor(charPos, headList, faceGroupList, verts, floorFaceList):
	faceGrp = bclsGetFaceGroup(charPos, headList)
	
	if not (faceGrp[X] < 0 or faceGrp[Y] < 0) : 
		bgridSizeX = headList[5];
		bgridSizeY = headList[4];

		if faceGrp[X] < bgridSizeX and faceGrp[Y] < bgridSizeY :	#if lookup grid position is in range,
			faceGroup = faceGroupList[faceGrp[X] + bgridSizeX * faceGrp[Y]]	#get the corresponding face group
			
			for faceIdx in faceGroup[1]:			#for each index in the floor face list
				face = floorFaceList[faceIdx]		#  get that face and its verts
				vert0 = verts[face[0]];
				vert1 = verts[face[1]];
				vert2 = verts[face[2]];
				
				#run the selection process
				tmp1 = vec2Sub(vert1, vert0)
				tmp2 = vec2Sub(charPos, vert0)
				
				if vec2Ukn(tmp2, tmp1) >= 0.0 :
					tmp2 = vec2Sub(vert2, vert1)
					tmp1 = vec2Sub(charPos, vert1)
					
					if  vec2Ukn(tmp1, tmp2) >= 0.0 :
						tmp2 = vec2Sub(vert0, vert2)
						tmp1 = vec2Sub(charPos, vert2)
						
						if  vec2Ukn(tmp1, tmp2) >= 0.0 :
							return faceIdx  # This is the selected face idx

	return -1	#no collision face under given coords
	
	
#Get the height of a point on a face (given by 3 verts)
def calcZ(v1, v2, v3, x, z):
	det = (v2[Y] - v3[Y]) * (v1[X] - v3[X]) + (v3[X] - v2[X]) * (v1[Y] - v3[Y])
	
	l1 = ((v2[Y] - v3[Y]) * (x - v3[X]) + (v3[X] - v2[X]) * (z - v3[Y])) / det
	l2 = ((v3[Y] - v1[Y]) * (x - v3[X]) + (v1[X] - v3[X]) * (z - v3[Y])) / det
	l3 = 1.0 - l1 - l2
	
	return l1 * v1[Z] + l2 * v2[Z] + l3 * v3[Z]


	
if len(sys.argv) != 3 and len(sys.argv) != 4:
	print('usage: ' + os.path.basename(sys.argv[0]) + ' [scale,hft] COLLISION.BCLS2 OUTPUT.{bmp|jpg|png}')
	print('  default scale = 50, h = heightmap colors, f = show faces, t = three color mode')
	print('  WARNING: Kinda slow, may take a long time if scale is large')
	exit(0)

scale = 50
bColor = False
bFace = False
bThree = False
iarg=1

if len(sys.argv) == 4:
	iarg=2
	tmp = sys.argv[1].split(",")
	if tmp[0].isnumeric():
		scale = int(tmp[0])
	bColor = 'h' in tmp[-1]
	bFace = 'f' in tmp[-1]
	bThree = 't' in tmp[-1]


with open(sys.argv[iarg], 'rb') as fIn:

	#skip SIR0 data
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
	
	#Read in Header List (Only first item, that's all there ever is)
	fIn.seek(listHeadPtr)
	listHead = unpack('<10i', fIn.read(40))
	
	#Read in verts
	listCoord = []
	fIn.seek(listCoordPtr)
	for x in range(0, listCoordSize):
		listCoord.append(unpack('<3f', fIn.read(12)))
	
	#Read in floor faces
	listFloor = []
	fIn.seek(listFloorPtr)
	for x in range(0, listFloorSize):
		listFloor.append(unpack('<6i', fIn.read(24)))
	
	#TODO: Read in wall faces?
	
	#Read in Face groups
	listGroup = []
	fIn.seek(listHead[7])
	for x in range(0, listHead[6]):
		listGroup.append(list(unpack('<4i', fIn.read(16))))
	
	for group in listGroup:
		if group[0] > 0:
			fIn.seek(group[1])
			group[1]=unpack('<{:d}i'.format(group[0]), fIn.read(group[0]*4))
		else:
			group[1]=()
			
		if group[2] > 0:
			fIn.seek(group[3])
			group[3]=unpack('<{:d}i'.format(group[2]), fIn.read(group[2]*4))
		else:
			group[3]=()
	
	
	maxX = float("-inf")
	minX = float("inf")
	maxY = float("-inf")
	minY = float("inf")
	maxZ = float("-inf")
	minZ = float("inf")
	for vert in listCoord:
		maxX = max(maxX, vert[X])
		minX = min(minX, vert[X])
		maxY = max(maxY, vert[Y])
		minY = min(minY, vert[Y])
		maxZ = max(maxZ, vert[Z])
		minZ = min(minZ, vert[Z])
	
	rangeX = maxX - minX
	rangeY = maxY - minY
	rangeZ = maxZ - minZ
	midZ = minZ + rangeZ/2
	
	mods = (0,5,10,15,20,25,30,35)
	r = 0
	g = 0

	#create a new image, default white
	img = Image.new('RGB', (math.floor(rangeX*scale),math.floor(rangeY*scale)), 'white')

	#set pixels in image based on presence of floor faces
	pixels = img.load()
	for i in range(img.size[0]):		#for each pixel
		for j in range(img.size[1]):
			face = bclsGetFloor((i/scale+minX,j/scale+minY), listHead, listGroup, listCoord, listFloor)	#get face at equivalent coord
			
			#if it's a valid face, color the pixel
			if face > -1:
				#If heightmap colors, get height of position and set color
				if bColor:
					z = calcZ(listCoord[listFloor[face][0]],listCoord[listFloor[face][1]],listCoord[listFloor[face][2]],i/scale+minX,j/scale+minY)
					if bThree:
						if z >= midZ:
							g = math.floor((z-midZ)/(rangeZ/2)*255)
							r = 0
						else:
							g = 0
							r = math.floor((midZ-z)/(rangeZ/2)*255)
					else:
						g = math.floor((z-minZ)/(rangeZ)*255)
						r = 0
						
				#If showing faces, give each a slightly different color
				if bFace:
					colorMod=-mods[face%len(mods)]
				else:
					colorMod=0
				
				#set the color of the current pixel
				pixels[i,j] = (r+colorMod,g+colorMod,255+colorMod-r-g)
			
		#Print current progress (it can take a while)
		print('Processing [%d%%]\r'%(100*i/img.size[0]+1), end="")
		
	img.save(sys.argv[iarg+1])
	print()
	