# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# ----------------------------------------
# Database Reset
# ----------------------------------------

# if Rails.env == 'development'
#   puts 'Reseting database'

#   Rake::Task['db:migrate:reset'].invoke
# end

# ----------------------------------------
# Seed Config Vars
# ----------------------------------------

TYPES = 18
POKEMON = 5
MULTIPLIER = 10
GENERATE_TYPES_BOOL = false
GENERATE_POKEMON_BOOL = false
GENERATE_USERS_BOOL = true
GENERATE_CATEGORIES_BOOL = true
GENERATE_QUESTIONS_BOOL = true
GENERATE_RESULTS_BOOL = true

# ----------------------------------------
# Setup API
# ----------------------------------------

@pokeapi = PokeAPI.new

# ----------------------------------------
# Make API calls for Type
# ----------------------------------------



# ----------------------------------------
# Populate database with Types
# ----------------------------------------



# ----------------------------------------
# Populate database with Type relationships
# ----------------------------------------
def generate_types

  puts "Making Type API calls"

  @pokeapi.get_all_types

  puts "Populating database with types"

  Type.destroy_all
  TypeRelationship.destroy_all

  all_types = @pokeapi.types

  (1..TYPES).each do |x|
    Type.create(name: all_types[x][:name] )
  end

  puts "Populating type_relationships with default normal effectiveness"

  (1..TYPES).each do |attack|
    (1..TYPES).each do |defend|
      relation_checker = false
      relations_hash = all_types[attack][:damage_relations]

      if relations_hash['no_damage_to'][0]
        if relations_hash['no_damage_to'].any? { |relation| relation["name"] == all_types[defend][:name] }
          TypeRelationship.create(attack_type_id: attack, defend_type_id: defend, effectiveness: "no_damage" )
          relation_checker = true
        end
      end

      if relations_hash['half_damage_to'][0]

        if relations_hash['half_damage_to'].any? { |relation| relation["name"] == all_types[defend][:name] }
          TypeRelationship.create(attack_type_id: attack, defend_type_id: defend, effectiveness: "half_damage" )
          relation_checker = true
        end
      end

      if relations_hash['double_damage_to'][0]
        if relations_hash['double_damage_to'].any? { |relation| relation["name"] == all_types[defend][:name] }
          TypeRelationship.create(attack_type_id: attack, defend_type_id: defend, effectiveness: "double_damage" )
          relation_checker = true
        end
      end
      TypeRelationship.create(attack_type_id: attack, defend_type_id: defend, effectiveness: "normal" ) if relation_checker == false
      
    end
  end
end

# ----------------------------------------
# Populate database with Pokemon
# ----------------------------------------

def generate_pokemon
  Pokemon.destroy_all

  (1..POKEMON).to_a.each do |x|
    puts "Getting Pokemon #{x}"
    @pokeapi.get_pokemon(x.to_s)
    pokemon = @pokeapi.pokemon_complete
    p = Pokemon.new(name: pokemon[:name], first_type_id: Type.find_by_name(pokemon[:types][0]).id)
    p.second_type_id = Type.find_by_name(pokemon[:types][1]).id if pokemon[:types][1]
    p.save!
  end
end

# ----------------------------------------
# Populate database with users, profiles
# ----------------------------------------

def generate_users
  # User.destroy_all
  # Profile.destroy_all

  MULTIPLIER.times do
    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    username = Faker::Company.name
    email = Faker::Internet.free_email("#{first_name} #{last_name}")
   
    user = User.new(email: email, password: 'qwerqwer')
    user.build_profile(first_name: first_name, last_name: last_name, username: username)
    user.save!
  end
end

# ----------------------------------------
# Populate database with categories
# ----------------------------------------
def generate_categories
  Category.destroy_all
  2.times do
    Category.create(name: Faker::Hipster.word)
  end
end

# ----------------------------------------
# Populate database with questions
# ----------------------------------------

def generate_questions
  Question.destroy_all
  MULTIPLIER.times do
    question = Faker::Lorem.sentence
    solution = Faker::Lorem.sentence
    Question.create(question: question, solution: solution, category_id: Category.all.sample.id, frequency: 0)
  end
end

# ----------------------------------------
# Populate database with results
# ----------------------------------------
def generate_results
  Result.destroy_all
  (MULTIPLIER * 3).times do
    user_id = User.all.sample.id
    question_id = Question.all.sample.id
    result = ['true', 'false'].sample
    Result.create(user_id: user_id, question_id: question_id, result: result)
  end
end

generate_types if GENERATE_TYPES_BOOL
generate_pokemon if GENERATE_POKEMON_BOOL
generate_users if GENERATE_USERS_BOOL
generate_categories if GENERATE_CATEGORIES_BOOL
generate_questions if GENERATE_QUESTIONS_BOOL
generate_results if GENERATE_RESULTS_BOOL

