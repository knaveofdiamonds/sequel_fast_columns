module Sequel
  class Dataset
    def columns
      return @columns if @columns
      @columns = if opts[:select] 
        if opts[:select].map(&:class).any? {|x| x == Sequel::LiteralString } ||
            (opts[:joins] && opts[:select].any? {|x| x == :* })
          query_db_for_columns
        else
          opts[:select].map do |column|
            case column
            when Sequel::SQL::AliasedExpression
              column.aliaz.to_sym
            when Sequel::SQL::QualifiedIdentifier
              column_name_from_symbol column.column
            when Sequel::SQL::ColumnAll
              get_all_columns(column.table)
            when Symbol
              column_name_from_symbol column
            when Sequel::SQL::Expression
              column.to_s(db).to_sym
            else
              column.to_s.to_sym
            end
          end.flatten
        end
      else
        if opts[:joins]
          query_db_for_columns
        else
          get_all_columns opts[:from]
        end
      end
    end

    private

    def get_all_columns(table)
      table = table.first if table.kind_of? Array
      if table.kind_of?(Symbol)
        db.schema(table).map {|c| c.first }
      else
        query_db_for_columns
      end
    end

    def column_name_from_symbol(column)
      if column == :*
        get_all_columns opts[:from]
      else
        t, col, aliaz = split_symbol(column)
        aliaz ? aliaz.to_sym : col.to_sym
      end
    end

    # This is the original Sequel Method
    def query_db_for_columns
      ds = unfiltered.unordered.clone(:distinct => nil, :limit => 1)
      ds.each{break}
      @columns = ds.instance_variable_get(:@columns)
      @columns || []
    end
  end
end
