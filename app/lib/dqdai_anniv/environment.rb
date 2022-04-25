module DqdaiAnniv
  class Environment < Ginseng::Environment
    def self.name
      return File.basename(dir)
    end

    def self.dir
      return dqdai-anniv.dir
    end
  end
end
