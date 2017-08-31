# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Document.create(doc_type: "text",
                text: "Muad'Dib is a fictional species of desert mouse. The people of the desert respect Muad'Dib, because Muad'Dib is wise in the ways of the desert: Muad'Dib creates his own water. Muad'Dib hides from the sun and travels in the cool night. Muad'Dib is fruitful and multiplies over the land.")
Document.create(doc_type: "text",
                text: "GLaDOS is a sentient computer. She promisses cake, but the cake is a lie.")

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
# User.create!(name:  "sesaba23",
#             email: "sesaba23@gmail.com",
#             password:              "foobar",
#             password_confirmation: "foobar",
#             admin: true)
   
# 99.times do |n|
#      name  = Faker::Name.name
#      email = "example-#{n+1}@railstutorial.org"
#      password = "password"
#      User.create!(name:  name,
#                   email: email,
#                   password:              password,
#                   password_confirmation: password,
#                   admin: false)
# end
