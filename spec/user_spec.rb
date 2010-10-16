require File.dirname(__FILE__) + "/spec_helper"

describe "User model" do
  context "Updating recipes" do
    it "should delete previous recipes and create new list" do
      user = User.get("Jimmy")

      user.run_list.should eql(["ruby", "ruby::irbrc", "node", "python", "erlang"])

      user.run_list = [ "ruby","mongodb" ]

      user.run_list.should eql(["ruby", "mongodb"])
    end
  end
end
