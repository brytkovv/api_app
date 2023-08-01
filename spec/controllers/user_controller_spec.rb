require 'rails_helper'
require 'faker'

RSpec.describe UsersController, type: :controller do
  describe 'GET #index' do

    let!(:users) { create_list(:user, 15) }

    it 'returns a successful response' do
      # Проверяем, что кэширование включено
      expect(Rails.application.config.action_controller.perform_caching).to be_truthy

      # Проверяем, что используется правильный кэш-хранилище (Redis)
      expect(Rails.cache).to be_an_instance_of(ActiveSupport::Cache::RedisCacheStore)

      expect(Rails.cache).to receive(:fetch).and_call_original
      get :index

      expect(response).to have_http_status(:success)
    end

    it 'returns a list of users' do
      get :index
      expect(JSON.parse(response.body).size).to eq(10)
    end

    it 'caches the response' do
      expect(Rails.cache).to receive(:fetch).and_call_original
      get :index
    end

    it 'returns the second page of users' do
      get :index, params: { page: 2 }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(5)
    end

    it 'filters users by date range' do
      user1 = create(:user, created_at: '2023-01-01')
      user2 = create(:user, created_at: '2023-02-01')
      user3 = create(:user, created_at: '2023-03-01')

      get :index, params: { created_after: '2023-02-01', created_before: '2023-03-01' }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).size).to eq(2)
    end

  end

  describe 'GET #show' do
    let!(:user) { create(:user) }

    it 'returns a successful response' do
      get :show, params: { id: user.id }
      expect(response).to have_http_status(:success)
    end

    it 'returns the user with posts and comments, comments testing' do
      post = create(:post, user: user)
      create_list(:comment, 3, post: post, user: user)

      get :show, params: { id: user.id }
      user_with_posts_and_comments = JSON.parse(response.body)

      expect(user_with_posts_and_comments['id']).to eq(user.id)
      expect(user_with_posts_and_comments['posts'].size).to eq(1)
      expect(user_with_posts_and_comments['posts_count']).to eq(1)
      expect(user_with_posts_and_comments['posts'][0]['comments'].size).to eq(3)
      expect(user_with_posts_and_comments['posts'][0]['comments_count']).to eq(3)

      comment1 = create(:comment, post: post, user: user)
      get :show, params: { id: user.id }
      user_with_posts_and_comments = JSON.parse(response.body)
      expect(user_with_posts_and_comments['posts'][0]['comments_count']).to eq(4)

      comment1.update(text: 'Abrakadabra')

      post1 = create(:post, user: user)
      get :show, params: { id: user.id }
      user_with_posts_and_comments = JSON.parse(response.body)

      expect(user_with_posts_and_comments['posts_count']).to eq(2)
      expect(user_with_posts_and_comments['posts'][0]['comments'][-1]['text']).to eq('Abrakadabra')

      post1.destroy
      comment1.destroy
      get :show, params: { id: user.id }
      user_with_posts_and_comments = JSON.parse(response.body)
      expect(user_with_posts_and_comments['posts_count']).to eq(1)
      expect(user_with_posts_and_comments['posts'][0]['comments_count']).to eq(3)

    end
  end

  describe 'POST #create' do
    let(:valid_params) { { user: { name: Faker::Name.name } } }

    it 'creates a new user' do
      expect {
        post :create, params: valid_params
      }.to change(User, :count).by(1)
    end

    it 'returns the newly created user' do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)

      new_user = JSON.parse(response.body)
      expect(new_user['name']).to eq(valid_params[:user][:name])
    end

    it 'returns errors for invalid user' do
      invalid_params = { user: { name: '' } }
      post :create, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)

      errors = JSON.parse(response.body)['errors']
      expect(errors['name']).to include("can't be blank")
    end
  end

  describe 'PUT #update' do
    let!(:user) { create(:user) }

    it 'updates the user' do
      put :update, params: { id: user.id, user: { name: 'Updated Name' } }
      user.reload

      expect(user.name).to eq('Updated Name')
    end

    it 'returns the updated user' do
      put :update, params: { id: user.id, user: { name: 'Updated Name' } }
      expect(response).to have_http_status(:success)

      updated_user = JSON.parse(response.body)
      expect(updated_user['name']).to eq('Updated Name')
    end

    it 'returns errors for invalid user update' do
      put :update, params: { id: user.id, user: { name: '' } }
      expect(response).to have_http_status(:unprocessable_entity)

      errors = JSON.parse(response.body)['errors']
      expect(errors['name']).to include("can't be blank")
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user) }
    let!(:post) { create(:post, user: user) }
    let!(:comment1) { create(:comment, user: user, post: post) }
    let!(:comment2) { create(:comment, user: user, post: post) }

    it 'deletes the user and all associated comments, but posts remain' do
      expect {
        delete :destroy, params: { id: user.id }
      }.to change(User, :count).by(-1)
                               .and change(Comment, :count).by(-2)
                                                           .and change(Post, :count).by(0)

      expect(response).to have_http_status(:no_content)

      # Убедимся, что связь с пользователем у всех комментариев была сброшена
      expect { comment1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { comment2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

