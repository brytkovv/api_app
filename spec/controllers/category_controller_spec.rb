require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  describe 'GET #index' do
    let!(:categories) { create_list(:category, 5) }

    it 'returns a successful response' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'returns a list of categories' do
      get :index
      expect(JSON.parse(response.body).size).to eq(5)
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { category:
                             { key: 'new_key', name: 'New Category', description: 'New Category Description' } } }

    it 'creates a new category' do
      expect {
        post :create, params: valid_params
      }.to change(Category, :count).by(1)
    end

    it 'returns the newly created category' do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)

      new_category = JSON.parse(response.body)
      expect(new_category['key']).to eq('new_key')
      expect(new_category['name']).to eq('New Category')
      expect(new_category['description']).to eq('New Category Description')
    end

    it 'returns errors for invalid category' do
      invalid_params = { category: { key: '', name: '', description: '' } }
      post :create, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)

      errors = JSON.parse(response.body)['errors']
      expect(errors['key']).to include("can't be blank")
      expect(errors['name']).to include("can't be blank")
    end
  end

  describe 'PUT #update' do
    let!(:category) { create(:category) }

    it 'updates the category' do
      put :update, params: { id: category.id, category:
        { name: 'Updated Category', description: 'Updated Description' } }
      category.reload

      expect(category.name).to eq('Updated Category')
      expect(category.description).to eq('Updated Description')
    end

    it 'returns the updated category' do
      put :update, params: { id: category.id, category:
        { name: 'Updated Category', description: 'Updated Description' } }
      expect(response).to have_http_status(:success)

      updated_category = JSON.parse(response.body)
      expect(updated_category['name']).to eq('Updated Category')
      expect(updated_category['description']).to eq('Updated Description')
    end

    it 'returns errors for invalid category update' do
      put :update, params: { id: category.id, category: { key: '' } }
      expect(response).to have_http_status(:unprocessable_entity)

      errors = JSON.parse(response.body)['errors']
      expect(errors['key']).to include("can't be blank")
    end
  end

  describe 'DELETE #destroy' do
    let!(:category) { create(:category) }
    let!(:post1) { create(:post, category: category) }
    let!(:post2) { create(:post, category: category) }
    let!(:comment1) { create(:comment, post: post1) }
    let!(:comment2) { create(:comment, post: post2) }

    it 'deletes the category and all associated posts and comments' do
      expect {
        delete :destroy, params: { id: category.id }
      }.to change(Category, :count).by(-1)
                                   .and change(Post, :count).by(-2)
                                                            .and change(Comment, :count).by(-2)

      expect(response).to have_http_status(:no_content)
    end
  end
end