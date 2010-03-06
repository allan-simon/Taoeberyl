#$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../../lib")

require 'rubygems'
require 'neo4j'

# we have to configure these before the model is loaded
Lucene::Config[:store_on_file] = true
Lucene::Config[:storage_path] = "tmp/lucene"

Neo4j::Config[:storage_path] = 'neodb'

require 'model'
require 'neo4j/extensions/reindexer'

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
    puts "-l <lang> search sentences from this lang (lang is its iso 639 alpha 3 code"
end


if __FILE__ == $0
    Neo4j.start

    if (ARGV.size == 2)

        if (ARGV[0] == "-w")

            Neo4j::Transaction.run do
                #Sentence.update_index
            end 
            findByWord(ARGV[1])
        elsif (ARGV[0] == "-l")
            Neo4j::Transaction.run do
                #Sentence.update_index
            end 
            findByLang(ARGV[1])
        else
            usage()
        end
    else
        usage()
    end

    Neo4j.stop 

end
