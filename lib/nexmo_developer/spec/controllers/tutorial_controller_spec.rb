require 'rails_helper'

RSpec.describe TutorialController, type: :controller do
  it 'renders' do
    get :list

    expect(response.status).to eq(200)
  end

  describe 'when a locale is present' do
    it 'redirects to the canonical url if locale is :en' do
      get :list, params: { locale: 'en' }

      expect(response).to redirect_to('/tutorials')
    end

    it 'renders when locale is different from :en' do
      get :list, params: { locale: 'cn' }

      expect(response.status).to eq(200)
    end
  end
end
