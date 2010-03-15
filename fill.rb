require 'rubygems'
require 'neo4j'

# we have to configure these before the model is loaded
Lucene::Config[:store_on_file] = true
Lucene::Config[:storage_path] = "tmp/lucene"

Neo4j::Config[:storage_path] = 'neodb'


require 'model'
require 'neo4j/extensions/reindexer'


# fill the dabase using a CVS file, the one you can find in tatoeba, download
# section
#
# TODO make the cvs parsing a bit more "clean"
# TODO avoid duplicate if running two times this method
#
# === Parameters 
#
# fileName<String>:: csv path
#
# === Returns
#
# nil
#

def fillDatabaseWithCSV(fileName)

    nbrSentences = 0
    tempSentence = nil
        
    File.open(fileName).each_line do |line|        
        
        if line.nil? 
            return
        end
        # don't handle line starting with #
        if line[0].chr == "#"
            next
        end
        columns = line.split(';"')
        
        if !columns.empty?
            transaction = nil
            # We start the transaction every 1000 sentences
            # otherwise it either to slow if we done one transaction
            # per sentence, or it run out of memory if we try to load
            # all the 300 000 sentences in one transaction
            #
            # TODO find a better way to do this
            
            if (nbrSentences.modulo 10000).equal? 0
                Neo4j::Transaction.new
            end
            tempSentence = Sentence.new
            tempSentence.text = columns.last[0..-4]
            tempSentence.lang = columns[1][0..-2];
            tempSentence.sentenceId = columns.first[1..-2]
            
            
            if (nbrSentences.modulo 10000).equal? 9999
                Neo4j::Transaction.finish
            end
            nbrSentences += 1
        end
    end
end

def fillLinks(linksFileName)
    nbrLinks = 0;
    tempLink = nil;

     

    File.open(linksFileName).each_line do |line|

    columns = line.split('";"')

        if !columns.empty?
            if (nbrLinks.modulo 10000).equal? 0
                Neo4j::Transaction.new
            end
            transaction = nil;
            sourceId = columns.first[1..-1]
            targetId = columns.last[0..-4]
            if sourceId == targetId
                next
            end 

            puts "#{sourceId} - #{targetId}"
            sourceResults = Sentence.find(:sentenceId => sourceId)
            if ! sourceResults.empty?
                sourceSentence = sourceResults[0]
                targetResults = Sentence.find(:sentenceId => targetId)
                if ! targetResults.empty?
                   targetSentence = targetResults[0]
                   if ! targetSentence.nil?
                        sourceSentence.translated_by.new(targetSentence)
                    end
                end 
            
            end
            if (nbrLinks.modulo 10000).equal? 9999
                Neo4j::Transaction.finish
            end
            
            nbrLinks += 1
        end
    end
end


if __FILE__ == $0
    Neo4j.start
    fileName = 'sentences_20100111.csv'
    fillDatabaseWithCSV(fileName)
    fileName = 'links_20100111.csv'
    fillLinks(fileName)
    Neo4j.stop
end

