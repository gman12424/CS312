#!/usr/bin/perl -s
#Geoffrey Ringlee (930862963)

#global variables for flags/placeholders for command line inputs
my $nameFlag = 0;
my $nameSearch = " ";
my $lsFlag = 0;
my $pwdFlag = 0;
my $grepFlag = 0;
my $grep = " ";

#While loop for parsing command line inputs
while (@ARGV){
    $myarg = shift(@ARGV);
    
   
    if($myarg =~"-name"){ #-name flag
        $nameFlag = 1;
        $nameSearch = &glob2pat(shift(@ARGV));
        $nameSearch =~ s/\\"//g;
    }elsif ($myarg =~ "-ls"){ #-ls flag
        $lsFlag = 1;
    }elsif ($myarg =~ "-pwd"){ #-pwd flag
        $pwdFlag = 1;
    }elsif ($myarg =~ "-grep"){ #-grep flag
        $grepFlag = 1;
        $grep = shift(@ARGV);
        $grep =~ s/\\"//g;
        
    }else{
        $start = $myarg; #for file input
    }
}

&ScanDirectory("$start"); 

# note the use of -s for switch processing. Under NT/2000, you will need to
# call this script explicitly with -s (i.e., perl -s script) if you do not
# have perl file associations in place. 
# -s is also considered 'retro', many programmers prefer to load
# a separate module (from the Getopt:: family) for switch parsing.

use Cwd; # module for finding the current working directory

# This subroutine takes the name of a directory and recursively scans 
# down the filesystem from that point looking for files named "core"
sub ScanDirectory{
    my ($workdir) = shift; 


    my ($startdir) = &cwd; # keep track of where we began

    chdir($workdir) or die "Unable to enter dir $workdir:$!\n";
    opendir(DIR, ".") or die "Unable to open $workdir:$!\n";
    my @names = readdir(DIR) or die "Unable to read $workdir:$!\n";
    closedir(DIR);
    my $pwdName;
    foreach my $name (@names){
        next if ($name eq "."); 
        next if ($name eq "..");
        
        
        if (-d $name){                  # is this a directory?
            &ScanDirectory($name);
            next;
        }
        
        if ($nameFlag){ #if name flag set, check to see if the name matches, and then skip the directory.
		if( "$name" =~ $nameSearch){
            
       		 }else{
			if(-d $name){
				&ScanDirectory($name);
			}
           		 next;
       		 }
	}
        
        if($pwdFlag){ #if pwdFlag is set, then reset name to the full file name
            $name = `readlink -f $name`;
            $name = substr($name, 0, -1);
            
                
       }
       
       if($lsFlag){ #if ls flag is set, print the ls return.
          $return = substr(system("ls $name -l"), 0, -1);
          print"$return";

       }elsif($grepFlag){ #if grep flag is set, then search the file, and if the grep word is found print the file, line number, and line it is found in
            $ct = 0;
		
            open($myFile, "$name") or die "Couldn't open file $name";
            while (<$myFile>) {
                $ct++;
                
                print "$name: $ct:\t$_" if /$grep/;
            }
            close($myFile) or die "Couldn't close file properly: $name";
                
        }else{ #if lsFlag and grepFlag are not set, then jest print the line number.
            
            print "$name\n";
        }
        

         
        
        
    }    
    chdir($startdir) or #at the end of the loop, change directory back to the starting directory.
        die "Unable to change to dir $startdir:$!\n";
    
}




sub glob2pat { #parses wildcard characters brought from command line to perl.
    my $globstr = shift;
    my %patmap = (
        '*' => '.*',
        '?' => '.',
        '[' => '[',
        ']' => ']',
    );
    $globstr =~ s{(.)} { $patmap{$1} || "\Q$1" }ge;
    return '^' . $globstr . '$';
}
