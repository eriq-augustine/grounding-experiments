require_relative '../../scripts/util.rb'

OUT_FILENAME = 'out-eval.txt'

def parseTuffyOutput(path)
   groundingFinishTimestamp = -1
   groundingTimestamp = -1
   querySize = -1

   File.open(path, 'r'){|file|
      file.each{|line|
         line = line.strip()

         if (match = line.match(/^(\d+)\s.*Grounding\.\.\.$/))
            groundingTimestamp = match[1].to_i()
         elsif (match = line.match(/^(\d+)\s.*### total grounding = /))
            groundingFinishTimestamp = match[1].to_i()
         elsif (match = line.match(/^#clauses = (\d+)$/))
            querySize = match[1].to_i()
         end
      }
   }

   return groundingFinishTimestamp - groundingTimestamp, querySize
end

def parsePSLOutput(path)
   queryFinishTimestamp = -1
   queryTimestamp = -1
   groundingFinishTimestamp = -1
   querySize = -1
   finalSize = -1

   File.open(path, 'r'){|file|
      file.each{|line|
         line = line.strip()

         if (match = line.match(/^(\d+)\s.+  - SELECT/))
            queryTimestamp = match[1].to_i()
         elsif (match = line.match(/^(\d+)\s.+  - Number of results: (\d+)$/))
            queryFinishTimestamp = match[1].to_i()
            querySize = match[2].to_i()
         elsif (match = line.match(/^(\d+)\s.+  - Grounded (\d+) instances of rule/))
            groundingFinishTimestamp = match[1].to_i()
            finalSize = match[2].to_i()
         end
      }
   }

   return queryFinishTimestamp - queryTimestamp, groundingFinishTimestamp - queryTimestamp, querySize, finalSize
end

def main(baseDir)
   headers = ['method', 'size', 'falsePercent', 'query time', 'total time', 'querySize', 'finalSize']
   stats = []

   Util.listDir(baseDir){|method, methodPath|
      Util.listDir(methodPath){|runId, runPath|
         size, falsePercent = runId.split('_')

         if (method.start_with?('psl'))
            queryTime, totalTime, querySize, finalSize = parsePSLOutput(File.join(runPath, OUT_FILENAME))
         elsif (method.start_with?('tuffy'))
            queryTime, querySize = parseTuffyOutput(File.join(runPath, OUT_FILENAME))
            totalTime = queryTime
            finalSize = querySize
         else
            puts "ERROR: Unknown method: [#{metho}]."
            exit(1)
         end

         stats << [method, size, falsePercent, queryTime, totalTime, querySize, finalSize]
      }
   }

   puts ([headers] + stats).map{|row| row.join("\t")}.sort().join("\n")
end

def loadArgs(args)
   if (args.size() > 1 || args.map{|arg| arg.gsub('-', '').downcase()}.include?('help'))
      puts "USAGE: ruby #{$0} [run results dir]"
      puts "   We will use '../out' (relative to this script's dir) as the result dir if none is provided."
      exit(1)
   end
   baseDir = File.join(File.dirname(File.dirname(File.absolute_path($0))), 'out')
   if (args.size() > 0)
      baseDir = args.shift()
   end

   return baseDir
end

if ($0 == __FILE__)
   main(*loadArgs(ARGV))
end
