
# Class which symbolise a sentence
#
# TODO add relations
# TODO add others fields
#
#

class Sentence
    include Neo4j::NodeMixin
    #a sentence can be the translation of several sentences
    #has_n :translates 
    # a sentece can be translated by several sentences
    #has_n(:translated_by).from(Sentence, :translates) 
    property :text, :lang, :sentenceId
    index :text, :tokenized => true
    index :lang, :sentenceId
    
    def to_s
        "Sentence  #{self.text}"
    end
end
