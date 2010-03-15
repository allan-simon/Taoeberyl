
# Class which symbolise a sentence
#
# TODO add relations
# TODO add others fields
#
#

class Sentence
    include Neo4j::NodeMixin
    #a sentence can be the translation of several sentences
    has_n :translates 
    # a sentece can be translated by several sentences
    has_n(:translated_by).from(Sentence, :translates) 
    
    property :text, :lang, :sentenceId
    index :text, :tokenized => true
    index :lang, :sentenceId
    
    def to_s
        "id : #{self.sentenceId} text : #{self.text}, lang #{self.lang}, "
    end

    def print_translation_and_indirect_translation
        directTranslations = Array.new()
        # we store self id in order to not display it in
        # indirect translations
        directTranslations << self.sentenceId
        indirectTranslations = Array.new
       
        # print all direct translation's text
        self.translated_by.each do |translation|
            directTranslations << translation.sentenceId
            puts translation.text
        end
        
        #self.rels.incoming(:translates).raw.nodes.each do |translation|
        #    #directTranslations << translation.sentenceId
        #    puts translation.props.inspect
        #end
        
        # print all translations of translations that are not already
        # direct translations
        puts "indirect translation now" 
        self.translated_by.each do |translation|
            translation.translated_by.each do |indirectTranslation|
                indirectId = indirectTranslation.sentenceId
                if !directTranslations.include? indirectId
                    if !indirectTranslations.include? indirectId
                        indirectTranslations << indirectId
                        puts indirectTranslation.text
                    end
                end
            end
        end
    end
end
