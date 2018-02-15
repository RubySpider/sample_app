require 'spec_helper'

describe "Static pages" do

  subject { page }
  
  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_title(full_title(page_title)) }
  end


  describe "Home page" do
    before { visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }

    it_should_behave_like "all static pages"
    it { should_not have_title('| Home') }
    
    # describe "pagination microposts" do
    #   before(:all) do
    #     @user = User.last || FactoryGirl.create(:user)
    #     50.times { FactoryGirl.create(:micropost, user: @user) }
    #     # binding.pry
    #     visit root_path
    #     sign_in @user
    #     visit root_path
    #   end
    #   after(:all) do 
    #     @user.microposts.delete_all
    #   end

    #   it { should have_selector('div.pagination') }

    #   it "should feed user microposts" do
    #     @user.microposts.paginate(page: 1).each do |micropost|
    #       expect(page).to have_selector('li', text: micropost.content)
    #     end
    #   end
    # end
      
    
    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end
      
     
      it "should pagination feed user microposts" do
        50.times { FactoryGirl.create(:micropost, user: user, content: "micropost content test") } 
        visit root_path
        
        should have_selector('div.pagination') 
        
        user.microposts.paginate(page: 1).each do |micropost|
            expect(page).to have_selector('li', text: micropost.content)
          end
        
        user.microposts.delete_all
      end
      
      # TODO: находить точное соответствие текста в теге по его id (..have_selector("span#micropost_count", text: "#{user.microposts.count} microposts") <span id="micropost_count">...</span>
      describe "number of microposts" do
        it "should show сorrect number of microposts" do 
          should have_content("#{user.microposts.count} microposts")
        end
        
        it "should show not сorrect number of microposts" do
          user.microposts.last.destroy
          visit root_path
          should have_content("#{user.microposts.count} micropost")
          should_not have_content("microposts")     
        end
      end
      
      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    let(:heading)    { 'Help' }
    let(:page_title) { 'Help' }
    
    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading)    { 'About' }
    let(:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
  end

  describe "Contact page" do
    before { visit contact_path }
    let(:heading)    { 'Contact' }
    let(:page_title) { 'Contact' }
    
    it_should_behave_like "all static pages"
  end
  
  
  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title(full_title('About Us'))
    click_link "Help"
    expect(page).to have_title(full_title('Help'))
    click_link "Contact"
    expect(page).to have_title(full_title('Contact'))
    click_link "Home"
    click_link "Sign up now!"
    expect(page).to have_title(full_title('Sign up'))
    click_link "sample app"
  end
end
