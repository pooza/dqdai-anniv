module DqdaiAnniv
  class Environment < Ginseng::Environment
    def self.name
      return File.basename(dir)
    end

    def self.dir
      return DqdaiAnniv.dir
    end
  end
end
