# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Document.create(doc_type: "text",
                text: "Some Orcas hunt Great Whites. They knock them out, suffacte them, and eat their livers.")
Document.create(doc_type: "text",
                text: "GLaDOS is a sentient computer. She promisses cake, but the cake is a lie.")

