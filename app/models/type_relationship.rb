class TypeRelationship < ActiveRecord::Base
  belongs_to :attack_type, class_name: 'PokemonType'
  belongs_to :defend_type, class_name: 'PokemonType'

  validates :attack_type, presence: true
  validates :defend_type, presence: true
  validates :attack_type_id, :uniqueness => { :scope => :defend_type_id, message: "This relationship already exists."}


end
