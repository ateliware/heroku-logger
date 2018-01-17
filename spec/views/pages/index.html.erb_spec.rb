require 'rails_helper'

RSpec.describe "pages/index.html.erb", type: :view do
  let!(:logs) { build_stubbed_list(:log, 45) }

  before(:example) do
    assign :query_params, {}
    assign :logs, logs
    assign :per_page, Kaminari.config.default_per_page
  end

  it "shows structured request data" do
    render
    expect(rendered).to have_css 'td', text: logs.sample.http_method
    expect(rendered).to have_css 'td', text: logs.sample.status
    expect(rendered).to have_css 'td', text: logs.sample.host
    expect(rendered).to have_css 'td', text: logs.sample.path
  end

  it "shows raw data when log is not in request format" do
    non_structured_data = 'some log with no structured data'
    non_structured_log = Log.new raw: non_structured_data
    assign :logs, logs + [non_structured_log]
    render
    expect(rendered).to include(non_structured_data)
  end

  it "auto fills query bar according to current search" do
    query = 'method=get'
    assign :query, query
    render
    expect(rendered).to have_css "#query[value='#{query}']"
  end
end
