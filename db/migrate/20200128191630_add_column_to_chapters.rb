class AddColumnToChapters < ActiveRecord::Migration[6.0]
  def change
    add_reference :chapters, :novel
  end
end
