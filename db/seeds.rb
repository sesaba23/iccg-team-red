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

# # Create fake user for development porposes
 User.create!(name:  "sesaba23",
             email: "sesaba23@gmail.com",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true)
   
 3.times do |n|
      name  = Faker::Name.name
      email = "user-#{n+1}@team-red.org"
      password = "password"
      User.create!(name:  name,
                   email: email,
                   password:              foobar,
                   password_confirmation: foobar,
                   admin: false)
 end
