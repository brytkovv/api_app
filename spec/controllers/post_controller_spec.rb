require 'rails_helper'
require 'faker'

RSpec.describe PostsController, type: :controller do
  describe 'POST #create' do
    let!(:category) { create(:category) }
    let!(:user) { create(:user) }
    let(:valid_params) { { category_id: category.key, post:
      { title: 'Заголовок', text: 'Текст поста', user_id: user.id } } }
    let(:invalid_params) { { category_id: category.key, post: { title: '', text: '', user_id: user.id } } }

    it 'creates a new post in the category' do
      expect {
        post :create, params: valid_params
      }.to change(Post, :count).by(1)
    end

    it 'returns the newly created post' do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)

      new_post = JSON.parse(response.body)
      expect(new_post['title']).to eq(valid_params[:post][:title])
    end

    it 'returns errors for invalid post' do
      post :create, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)

      errors = JSON.parse(response.body)['errors']
      expect(errors['title']).to include("can't be blank")
    end

    it 'returns an error for a non-existent category' do
      invalid_params[:category_id] = 999
      post :create, params: invalid_params

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    let!(:category) { create(:category) }
    let!(:post) { create(:post, category: category) }
    let!(:comment1) { create(:comment, post: post) }
    let!(:comment2) { create(:comment, post: post) }

    it 'deletes the post and all associated comments' do
      expect {
        delete :destroy, params: { id: post.id, category_id: category.id }
      }.to change(Post, :count).by(-1)
                               .and change(Comment, :count).by(-2)

      expect(response).to have_http_status(:no_content)

      expect { comment1.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { comment2.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'PUT #update' do
    let!(:category) { create(:category) }
    let!(:user) { create(:user) }
    let!(:post) { create(:post, category: category, user: user) }
    let(:valid_params) { { title: 'Новый заголовок', text: 'Новый текст поста' } }
    let(:invalid_params) { { title: '', text: '' } }

    context 'with valid params' do
      it 'updates the post' do
        put :update, params: { id: post.id, post: valid_params, category_id: category.id }
        expect(response).to have_http_status(:ok)

        updated_post = Post.find(post.id)
        expect(updated_post.title).to eq(valid_params[:title])
        expect(updated_post.text).to eq(valid_params[:text])
      end
    end

    context 'with invalid params' do
      it 'returns errors' do
        put :update, params: { id: post.id, post: invalid_params, category_id: category.id }
        expect(response).to have_http_status(:unprocessable_entity)

        errors = JSON.parse(response.body)['errors']
        expect(errors).to include("Title can't be blank")
      end
    end

    context 'with non-existent post' do
      it 'returns an error' do
        put :update, params: { id: 999, post: valid_params, category_id: category.id }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

end
