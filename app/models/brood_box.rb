class BroodBox < ActiveRecord::Base
	belongs_to :inspection

	# returns a list of fields as a human readable list
	def sightings
		fields = []
		fields.push 'Eggs' if self.eggs_sighted
		fields.push 'Queen' if self.queen_sighted
		fields.push 'Honey' if self.honey_sighted
		fields.push 'Pollen' if self.pollen_sighted

		fields.push 'Supercedure Cells' if self.supercedure_cell_sighted
		
		if self.swarm_cell_sighted
			if self.swarm_cells_capped
				fields.push 'Capped Swarm Cells'
			else
				fields.push 'Uncapped Swarm Cells'
			end
		end
		fields.join(', ')
	end
end
