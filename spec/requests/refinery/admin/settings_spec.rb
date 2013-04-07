require "spec_helper"

module Refinery
  module Admin
    describe "Settings" do
      login_refinery_user

      context "when no settings" do
        before(:each) { Refinery::Setting.destroy_all }

        it "invites to create one" do
          visit refinery.admin_settings_path
          page.should have_content("There are no settings yet. Click 'Add new setting' to add your first setting.")
        end
      end

      it "shows add new setting link" do
        visit refinery.admin_settings_path
        page.should have_content("Add new setting")
        page.should have_selector("a[href*='/refinery/settings/new']")
      end

      context "new/create" do
        it "adds setting", :js => true do
          visit refinery.admin_settings_path
          click_link "Add new setting"

          page.should have_selector('iframe#dialog_iframe')

          page.within_frame('dialog_iframe') do
            fill_in "Name", :with => "test setting"
            fill_in "Value", :with => "true"

            click_button "Save"
          end

          page.should have_content("'Test Setting' was successfully added.")
          page.should have_content("Test Setting - true")
        end
      end
      
      context "edit/update" do
        before(:each) {::Refinery::Setting.set(:rspec_testing_edit_and_update, 1)}
        
        it "modifies setting", :js => true do
          visit refinery.admin_settings_path
          find("a[href*='/refinery/settings/rspec_testing_edit_and_update/edit']").click
          
          page.should have_selector('iframe#dialog_iframe')
          page.within_frame('dialog_iframe') do
            
            find_field('Title').value.should eql("Rspec Testing Edit And Update")
            
            fill_in "Title", :with => "Edit and Update Title"
            fill_in "Value", :with => "2"

            click_button "Save"
          end
          
          page.should have_content("'Edit and Update Title' was successfully updated.")
          page.should have_content("Edit and Update Title - 2")
        end
      end

      context "pagination" do
        before(:each) do
          (Refinery::Setting.per_page + 1).times do
            FactoryGirl.create(:setting)
          end
        end

        specify "page links" do
          visit refinery.admin_settings_path

          page.should have_selector("a[href*='settings?page=2']")
        end
      end
    end
  end
end
