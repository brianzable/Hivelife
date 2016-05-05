class Disease < ActiveRecord::Base
	belongs_to :inspection

	VALID_DISEASES = [
    'Varroa mites',
    'Acarine (Tracheal) mites',
    'Nosema',
    'Small hive beetle',
    'Wax moths',
    'Tropilaelaps',
    'American foulbrood',
    'European foulbrood',
    'Chalkbrood',
    'Stonebrood',
    'Cripaviridae',
    'Dicistroviridae',
    'Chronic bee paralysis virus',
    'Acute bee paralysis virus',
    'Israeli acute paralysis virus',
    'Kashmir bee virus',
    'Black queen cell virus',
    'Cloudy wing virus',
    'Sacbrood virus',
    'Iflaviridae',
    'Deformed wing virus',
    'Kakugo virus',
    'Iridoviridae',
    'Invertebrate iridescent virus type 6',
    'Secoviridae',
    'Tobacco ringspot virus',
    'Lake Sinai virus',
    'Dysentery',
    'Chilled brood',
    'Pesticide losses',
    'Other'
  ]

	VALID_TREATMENTS = [
    'Acetic Acid',
    'Api-Life VAR',
    'Apiguard',
    'Apistan',
    'Apivar',
    'Brood Comb Replacement',
    'CheckMite+™',
    'Coumaphos Strips',
    'Drone Brood Removal',
    'Formic Acid',
    'Fumagilin-B',
    'Guard Star',
    'Hivastan',
    'HopGuard',
    'MAQS ™',
    'Mite-A-Thol ®',
    'Oxalic Acid',
    'Powder Sugar Roll',
    'Small Cell Comb',
    'Small Hive Beetle Traps',
    'Soil Drench',
    'Terra-Pro',
    'Terramycin™',
    'Tylan ®',
    'Other'
  ]

  validates :disease_type, inclusion: VALID_DISEASES, allow_blank: false
  validates :treatment, inclusion: VALID_TREATMENTS, allow_blank: true
end
