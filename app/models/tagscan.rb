class Tagscan < ApplicationRecord
    belongs_to :tag

    def tag_epc
        tag.try(:epc)
    end
    
    def tag_pc
        tag.try(:pc)
    end

    def tag_epc=(epc)
        self.tag = Tag.find_or_create_by(epc: epc) if epc.present?
    end

    def tag_pc=(pc)
        # this doesn't seem very efficient?
        self.tag = Tag.find_by(epc: self.tag_epc) if pc.present?
        self.tag.pc = pc
        self.tag.save
    end
end
