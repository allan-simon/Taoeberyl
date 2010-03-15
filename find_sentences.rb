#$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../../lib")

require 'rubygems'
require 'neo4j'

# we have to configure these before the model is loaded
Lucene::Config[:store_on_file] = true
Lucene::Config[:storage_path] = "tmp/lucene"

Neo4j::Config[:storage_path] = 'neodb'

require 'model'
require 'neo4j/extensions/reindexer'
require 'neo4j/extensions/graph_algo'

#
# Find all sentences containing the given word
#
# === Parameters
# 
# word<String>:: the word to find
#
# === Returns 
#
# nil

def findByWord(word)
    Neo4j::Transaction.run do
        puts "Find all sentence with #{word}"
        result = Sentence.find(:text => word)

        puts "Found #{result.size} sentences"
       
        result.each {|x| puts "#{x}"}
    end
end

def findById(id)
    Neo4j::Transaction.run do
        puts "Find all sentence # #{id}"
        
        startTime =  Time.now
        result = Sentence.find(:sentenceId => id)
        puts "Time elapsed: #{Time.now - startTime} seconds"

        #puts "Found #{result.size} sentences"
         
        result.each do |sentence|
            sentence.print_translation_and_indirect_translation
        end
        
    end
end

def findAllTranslations(sentenceNode)
    puts sentenceNode
    sentenceNode.rels(:translated_by).each do |translation|
        puts translation
    end     
end

#
# Find all sentences of the given language
#
# === Parameters
# 
# lang<String>:: the language to find, iso 639 alpha3 format
#
# === Returns 
#
# nil

def findByLang(lang)
    Neo4j::Transaction.run do
        puts "Find all sentence with lang #{lang}"
        result = Sentence.find(:lang => lang)

        puts "Found #{result.size} sentences"
       
        result.each {|x| puts "#{x}"}
    end
end

# Print how to use this software
# 
# === Returns
# nil
#


def usage()
    puts "you can use it wih the following options"
    puts "-w <a word> search sentences containing this word"
    puts "-i <id> search sentences with this id"
    puts "-l <lang> search sentences from this lang (lang is its iso 639 alpha 3 code"
end


if __FILE__ == $0
    Neo4j.start

    if (ARGV.size == 2)

        #TODO add an option to activate or not the preload in memory
        #Neo4j::Transaction.run do    
        #Sentence.update_index
        #end 
        startTime =  Time.now
        if (ARGV[0] == "-w")
            findByWord(ARGV[1])

        elsif (ARGV[0] == "-l")
            findByLang(ARGV[1])
            
        elsif (ARGV[0] == "-i")
            findById(ARGV[1])
        else 
            usage()
        end
    puts "Time elapsed: #{Time.now - startTime} seconds"
    else
        usage()
    end

    Neo4j.stop 

end
