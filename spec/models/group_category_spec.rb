# SKIP(Social Knowledge & Innovation Platform)
# Copyright (C) 2008 TIS Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GroupCategory, 'validation' do
  before do
    @group_category = valid_group_category
  end
  it 'codeが必須であること' do
    @group_category.code = ''
    @group_category.valid?.should be_false
  end
  it 'codeがユニークであること' do
    create_group_category(:code => 'SPORTS')
    @group_category.code = 'SPORTS'
    @group_category.valid?.should be_false
  end
  it 'codeが20文字以下であること' do
    @group_category.code = SkipFaker.rand_char(21)
    @group_category.valid?.should be_false
    @group_category.code = SkipFaker.rand_char(20)
    @group_category.valid?.should be_true
  end

  it 'nameが必須であること' do
    @group_category.name = ''
    @group_category.valid?.should be_false
  end
  it 'nameが20文字以下であること' do
    @group_category.name = SkipFaker.rand_char(21)
    @group_category.valid?.should be_false
    @group_category.name = SkipFaker.rand_char(20)
    @group_category.valid?.should be_true
  end

  it 'iconが必須であること' do
    @group_category.icon = ''
    @group_category.valid?.should be_false
  end
  it 'iconが20文字以下であること' do
    @group_category.icon = SkipFaker.rand_char(21)
    @group_category.valid?.should be_false
    @group_category.icon = SkipFaker.rand_char(20)
    @group_category.valid?.should be_true
  end

  it 'descriptionが255文字以下であること' do
    @group_category.description = SkipFaker.rand_char(256)
    @group_category.valid?.should be_false
    @group_category.description = SkipFaker.rand_char(255)
    @group_category.valid?.should be_true
  end
end

describe GroupCategory, '#before_save' do
  describe 'initial_selectedなレコードを保存する場合' do
    before do
      @new_group_category = valid_group_category
      @new_group_category.attributes = {:code => 'EMACS', :name => 'EMACS', :initial_selected => true}
    end
    describe 'まだinitial_selectedなレコードが存在しない場合' do
      it '正常に保存できること' do
        @new_group_category.save.should be_true
      end
    end
    describe 'initial_selectedなレコードが存在する場合' do
      before do
        @group_category = create_group_category(:code => 'VIM', :name => 'VIM', :initial_selected => true)
      end
      describe '新規登録の場合' do
        it '登録済みのGroupCategoryのinitial_selectedがfalseになること' do
          @new_group_category.save!
          @group_category.reload
          @group_category.initial_selected.should be_false
        end
      end
      describe '更新の場合' do
        before do
          # 事前にfalseで保存されている
          @new_group_category.initial_selected = false
          @new_group_category.save!
        end
        it '登録済みのGroupCategoryのinitial_selectedがfalseになること' do
          # trueに更新する
          @new_group_category.toggle!(:initial_selected)
          @group_category.reload
          @group_category.initial_selected.should be_false
        end
      end
    end
  end
end

def valid_group_category
  group_category = GroupCategory.new({
    :code => 'DEPT',
    :name => '部署',
    :icon => 'group_gear',
    :description => '部署用のグループカテゴリ',
    :initial_selected => false
  })
  group_category
end

def create_group_category(options = {})
  group_category = valid_group_category
  group_category.attributes = options
  group_category.save!
  group_category
end
