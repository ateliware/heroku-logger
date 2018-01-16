require 'rails_helper'

RSpec.describe PagesController, type: :controller do

  describe "GET #index" do
    before(:example) do
      build_list(:log, 5).each &:save
      Log.refresh_index!
    end

    context "for unsigned users" do
      it 'is only allowed for signed in users' do
        get :index
        expect(response).to redirect_to new_session_path
      end
    end

    context "for signed users" do
      before(:example) do
        @request.session[:signed_in] = true
      end

      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end

      it "assign @logs with elasticsearch Logs" do
        get :index
        expect(assigns(:logs)).to be_present
        expect(assigns(:logs).map(&:class).uniq).to eq([Log])
      end

      it "assign @logs paginated" do
        build_list(:log, Kaminari.config.default_per_page).each &:save
        Log.refresh_index!
        get :index
        expect(assigns(:logs).size).to eq(Kaminari.config.default_per_page)
      end
    end
  end
end
