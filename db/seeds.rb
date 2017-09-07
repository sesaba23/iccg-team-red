# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Document.create(doc_type: "text",
                text: "Muad'Dib is a fictional species of desert mouse. The people of the desert respect Muad'Dib, because Muad'Dib is wise in the ways of the desert: Muad'Dib creates his own water. Muad'Dib hides from the sun and travels in the cool night. Muad'Dib is fruitful and multiplies over the land.")

text = "The Ant and the Dove 


  AN ANT went to the bank of a river to quench its thirst, and
being carried away by the rush of the stream, was on the point of
drowning.  A Dove sitting on a tree overhanging the water plucked
a leaf and let it fall into the stream close to her.  The Ant
climbed onto it and floated in safety to the bank.  Shortly
afterwards a birdcatcher came and stood under the tree, and laid
his lime-twigs for the Dove, which sat in the branches.  The Ant,
perceiving his design, stung him in the foot.  In pain the
birdcatcher threw down the twigs, and the noise made the Dove
take wing.


	One good turn deserves another"

Document.create(doc_type: "text", text: text)

User.create!(name:  "Kirill",
            email: "kirmesh@gmail.com",
            password:              "super_pw",
            password_confirmation: "super_pw",
            admin: true)

User.create!(name:  "CoolOrcaGuy",
            email: "orcinus@orca.ocean",
            password:              "super_pw",
            password_confirmation: "super_pw",
            admin: true)

User.create!(name:  "Sam",
            email: "sam@sg1.gov",
            password:              "super_pw",
            password_confirmation: "super_pw",
            admin: true)


# # Create fake user for development porposes
 User.create!(name:  "sesaba23",
             email: "sesaba23@gmail.com",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true)
   
 3.times do |n|
      #name  = Faker::Name.name
      name = "user-#{n+1}"
      email = "user-#{n+1}@team-red.org"
      password = "password"
      User.create!(name:  name,
                   email: email,
                   password:              "foobar",
                   password_confirmation: "foobar",
                   admin: false)
 end
