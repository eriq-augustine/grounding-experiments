require 'fileutils'
require 'json'

SIMILAR_FILENAME = 'similar_obs.txt'
OPTIONS_FILENAME = 'options.json'

COPY_FILES = [
   'friends_targets.txt',
   'friends_truth.txt',
   'location_obs.txt'
]

def writeOptions(inPath, outPath, falseChance)
   options = JSON.parse(File.read(inPath))
   options['falseChance'] = falseChance
   File.write(outPath, JSON.pretty_generate(options))
end

def writeSimilarities(inPath, outPath, falseChance)
   File.open(inPath, 'r') {|inFile|
      File.open(outPath, 'w') {|outFile|
         inFile.each{|line|
            parts = line.strip().split("\t")

            if (Random.rand() < falseChance)
               parts[2] = 0
            else
               parts[2] = 1
            end

            outFile.puts(parts.join("\t"))
         }
      }
   }
end

def main(baseDataDir, outDir, falseChance)
   FileUtils.mkdir_p(outDir)

   # First just copy the untouched files over.
   COPY_FILES.each{|filename|
      FileUtils.cp(File.join(baseDataDir, filename), File.join(outDir, filename))
   }

   writeSimilarities(File.join(baseDataDir, SIMILAR_FILENAME), File.join(outDir, SIMILAR_FILENAME), falseChance)
   writeOptions(File.join(baseDataDir, OPTIONS_FILENAME), File.join(outDir, OPTIONS_FILENAME), falseChance)
end

def loadArgs(args)
   if (args.size() != 3 || args.map{|arg| arg.gsub('-', '').downcase()}.include?('help'))
      puts "USAGE: ruby #{$0} <base data dir> <out dir> <false percent>"
      exit(1)
   end

   baseDataDir = args.shift()
   outDir = args.shift()
   falseChance = args.shift.to_f()

   return baseDataDir, outDir, falseChance
end

if ($0 == __FILE__)
   main(*loadArgs(ARGV))
end
