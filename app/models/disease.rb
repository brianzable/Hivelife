class Disease < ActiveRecord::Base
	DISEASES = [["Acarine", "Acarine"],
							["AFB", "AFB"],
							["Africanized Bees", "Africanized Bees"],
							["Chalkbrood", "Chalkbrood"],
							["Dysentery", "Dysentery"],
							["European Foul Brood", "European Foul Brood"],
							["Laying Workers", "Laying Workers"],
							["Small Hive Beetle", "Small Hive Beetle"],
							["Varroa", "Varroa"],
							["Wax Moth", "Wax Moth"]]

	TREATMENTS = ["Acetic Acid",
								"Api-Life VAR",
								"Apistan®",
								"Apivar",
								"Brood Comb Replacement",
								"CheckMite+™",
								"Coumaphos Strips" ,
								"Drone Brood Removal",
								"Formic Acid",
								"Fumagilin-B",
								"Guard Star",
								"Hivastan",
								"MAQS™",
								"Mite-A-Thol®",
								"Powder Sugar Roll",
								"Small Cell Comb",
								"Small Hive Beetle Traps",
								"Soil Drench",
								"Terra-Pro",
								"Terramycin™",
								"Tylan®"]

	belongs_to :inspection
end
