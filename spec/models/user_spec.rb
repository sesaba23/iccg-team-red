require 'rails_helper'

describe User do
    describe 'Creates a User that needs valid fields' do
        before :each do
            @user = User.new(name: "Example User", email: "user@example.com",
                password: "foobar", password_confirmation: "foobar")
        end
        it 'should be valid' do
            expect(@user).to be_valid
        end
        it 'name should be present' do
            @user.name = "   "
            expect(@user).to_not be_valid
        end
        it 'email should be present' do
            @user.email = "   "
            expect(@user).to_not be_valid
        end
        it 'name should not be too long' do
            @user.name = "a" * 51
            expect(@user).to_not be_valid
        end
        it 'email should not be too long' do
            @user.email = "a" * 244 + "@example.com"
            expect(@user).to_not be_valid
        end
        it 'email validation should accept valid addresses' do
            valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
            first.last@foo.jp alice+bob@baz.cn]
            valid_addresses.each do |valid_address|
                @user.email = valid_address
                expect(@user).to be_valid "#{valid_address.inspect} should be valid"
            end
        end
        it 'email validation should reject invalid addresses' do
            invalid_addresses = %w[user@example,com USER_at_foo.COM user.name@example.
            foo@bar_baz.com foo@bar+baz.com]
            invalid_addresses.each do |invalid_address|
                @user.email = invalid_address
                expect(@user).to_not be_valid "#{invalid_address.inspect} should be valid"
            end
        end
        it 'email addresses should be unique' do
            duplicate_user = @user.dup
            duplicate_user.email = @user.email.upcase
            @user.save
            expect(duplicate_user).to_not be_valid
        end
        it 'email addresses should be saved as lower-case' do
            mixed_case_email = "Foo@EXAMPLE.CoM"
            @user.email = mixed_case_email
            @user.save
            expect(mixed_case_email.downcase).to_not be_equal @user.reload.email
        end

        it 'password should be present (nonblanck)' do
            @user.password = @user.password_confirmation = " " * 6
            expect(@user).to_not be_valid
        end
        it 'password should have a minimun length' do
            @user.password = @user.password_confirmation = "a" * 5
            expect(@user).to_not be_valid
        end

    end
end
