class AddColumnToNovel < ActiveRecord::Migration[6.0]
  def change
    add_reference :novels, :user
  end
end
