require File.dirname(__FILE__) + "/spec_helper"

describe "User model" do
  context "Updating recipes" do
    it "should delete previous recipes and create new list" do
      user = User.new(:name => "Jimmy")

      user.recipes << Recipe.new(:name => "node")
      user.save

      user.run_list = [ "ruby","mongodb" ]

      user.recipes.count.should == 2
      user.recipes[0].name.should == "ruby"
    end
  end
end
