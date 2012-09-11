require 'spec_helper'

describe "Micropost pages" do
  
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
  	before { visit root_path }

  	describe "with invalid information" do

  		it "should not create a micropost" do
  			expect { click_button "Post" }.not_to change(Micropost, :count)
  		end

  		describe "error messages" do
  			before { click_button "Post" }
  			it { should have_content('error') }
  		end
  	end

  	describe "with valid information" do

  		before { fill_in 'micropost_content', with: "Lorem ipsum" }
  		it "should create a micropost" do
  			expect { click_button "Post" }.to change(Micropost, :count).by(1)
  		end
  	end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end

    describe "as a incorrect user" do
      let(:new_user) { FactoryGirl.create(:user) }
      let(:new_micropost) { FactoryGirl.create(:micropost, user: user) }
      before { visit user_path(new_user) }

      it { should_not have_link("delete", href: microposts_path(new_micropost)) }
    end
  end

  describe "micropost pagination" do
    before do
      50.times { FactoryGirl.create(:micropost, user: user) }
      visit user_path(user)
    end

    it { should have_link('Next') }
    its(:html) { should match('>2</a>') }

    it "should list each micropost" do
      user.microposts.paginate(page: 1).each do |micropost|
        page.should have_selector("li", text: micropost.content)
      end
    end
  end

  describe "sidebar" do

    describe "for users with no one micropost" do
      it { should_not have_content("#{user.microposts.count} micropost") }
    end

    describe "for users with one micropost" do
      before do
        FactoryGirl.create(:micropost, user: user)
        sign_in user
        visit root_path
      end
      it { should have_content("1 micropost") }
    end

    describe "for users with more than one micropost" do
      before do
        FactoryGirl.create_list(:micropost, 31, user: user)
        sign_in user
        visit root_path
      end

      it { should have_content("#{user.microposts.count} microposts") }
    end
  end

end
