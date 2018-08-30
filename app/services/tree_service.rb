class TreeService

  LEVELS = ['themes', 'sub_themes', 'categories', 'indicators']

  def self.prune(tree=[], ids=[])

    return [] if ids.blank? || !tree.instance_of?(Array)

    @@ids = ids.map(&:to_i)

    pruned = self.filter_out({'themes' => tree.deep_dup}, 0)

    pruned ? pruned['themes'] : []

  end

  private

    def self.filter_out(node, level)

      return false if !node.instance_of?(Hash) || !node.key?(self::LEVELS[level])

      subnodes = node[ self::LEVELS[level] ]

      return false if !subnodes.instance_of?(Array)

      subnodes.select! do |subnode|
        if level == self::LEVELS.count - 1
          subnode.instance_of?(Hash) && subnode.key?('id') && @@ids.include?( subnode['id'] )
        else
          self.filter_out(subnode, level+1)
        end
      end

      subnodes.count>0 ? node : false

    end

end