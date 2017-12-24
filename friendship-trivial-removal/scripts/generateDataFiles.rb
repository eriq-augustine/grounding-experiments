require_relative 'generateFriendshipData'

SIZE_SEARCH_PATTERN = '__fold__'

def main(templatePath, fold, outPath)
   File.open(templatePath, 'r'){|inFile|
      File.open(outPath, 'w'){|outFile|
         inFile.each{|line|
            outFile.puts(
                  line
                  .gsub(SIZE_SEARCH_PATTERN, fold)
            )
         }
      }
   }
end

def loadArgs(args)
   if (args.size() != 3 || args.map{|arg| arg.gsub('-', '').downcase()}.include?('help'))
      puts "USAGE: ruby #{$0} <model template> <out path> <fold>"
      puts "   model template - the path to the template data file to use."
      puts "   out path - the path to place the replaced template at."
      puts "   fold - the fold (number of people) to use."
      exit(1)
   end

   templatePath = args.shift()
   outPath = args.shift()
   fold = args.shift()

   return templatePath, fold, outPath
end

if ($0 == __FILE__)
   main(*loadArgs(ARGV))
end
