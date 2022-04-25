module DqdaiAnniv
  module Refines
    class ::Integer
      def to_time
        return Time.at(self / 1000)
      end
    end
  end
end
