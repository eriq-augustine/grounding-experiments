require 'fileutils'

# Open up String and add a float checking method.
# http://mentalized.net/journal/2011/04/14/ruby-how-to-check-if-a-string-is-numeric/
class String
   def numeric?
      Float(self) != nil rescue false
   end
end

# Returns: [weight, ...]
# Note that Tuffy 1-indexes, and this will correct back to a zero-index.
# Tuffy will also group some rules togther and differentiate them with the floating-point portion of the number.
# So, we will just sort all the weights by their commented number.
def parseWeights(learningOutputPath)
   weights = {}

   File.open(learningOutputPath, 'r'){|file|
      file.each{|line|
         if (match = line.match(/^(-?\d+\.?\d*)\s.*\s\/\/(\d+\.\d+)?$/))
            if (!match[1].numeric?)
               raise("Found non-float rule: #{learningOutputPath}.")
            end

            weights[match[2].to_f()] = match[1]
         end
      }
   }

   return weights.to_a().sort().map{|id, weight| weight}
end

def main(mlnProgramPath, learningOutputPath, outPath)
   FileUtils.mkdir_p(File.dirname(outPath))

   weights = parseWeights(learningOutputPath)
   ruleIndex = 0

   File.open(mlnProgramPath, 'r'){|inFile|
      File.open(outPath, 'w'){|outFile|
         inFile.each{|line|
            if (match = line.match(/^(\d+\.?\d*)(\s.*)$/))
               if (ruleIndex >= weights.size())
                  raise("Found more rules than weights: #{learningOutputPath}.")
               end

               line = "#{weights[ruleIndex]} #{match[2]}"
               ruleIndex += 1
            end

            outFile.puts(line)
         }
      }
   }

   if (ruleIndex < weights.size())
      raise("Found more weights than rules: #{learningOutputPath}.")
   end
end

def loadArgs(args)
   if (args.size() != 3 || args.map{|arg| arg.gsub('-', '').downcase()}.include?('help'))
      puts "USAGE: ruby #{$0} <base mln program> <weight learning output> <out path>"
      exit(1)
   end

   mlnProgramPath = args.shift()
   learningOutputPath = args.shift()
   outPath = args.shift()

   return mlnProgramPath, learningOutputPath, outPath
end

if ($0 == __FILE__)
   main(*loadArgs(ARGV))
end
