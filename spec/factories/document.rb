FactoryGirl.define do
    factory :document do
        #default values
        id 1
        kind 'text'
        title 'Orcas'
        content 'Some Orcas hunt Great Whites. They knock them out, suffocate them, and eat their livers.'
    end
end
