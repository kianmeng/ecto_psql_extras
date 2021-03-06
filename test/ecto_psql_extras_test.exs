defmodule EctoPSQLExtrasTest do
  use ExUnit.Case, async: true

  import EctoPSQLExtras

  test "all queries define info" do
    for pair <- queries() do
      {name, module} = pair
      assert is_atom(name)

      info = module.info()
      assert info.title

      for column <- info.columns do
        assert column.name
        assert column.type
      end

      for {order_by, dir} <- info[:order_by] || [] do
        assert dir in [:asc, :desc]
        assert Enum.find(info.columns, &(&1.name == order_by))
      end
    end
  end

  test "format bytes" do
    assert format_value({0, :bytes}) == "0 bytes"
    assert format_value({1000, :bytes}) == "1000 bytes"
    assert format_value({1024, :bytes}) == "1.0 KB"
    assert format_value({1200, :bytes}) == "1.2 KB"
    assert format_value({1024 * 1024, :bytes}) == "1.0 MB"
    assert format_value({1024 * 1200, :bytes}) == "1.2 MB"
    assert format_value({1024 * 1024 * 1024, :bytes}) == "1.0 GB"
    assert format_value({1024 * 1024 * 1200, :bytes}) == "1.2 GB"
    assert format_value({1024 * 1024 * 1024 * 1024, :bytes}) == "1.0 TB"
    assert format_value({1024 * 1024 * 1024 * 1024 * 1024, :bytes}) == "1024.0 TB"
  end

  test "format structs" do
    assert format_value({Decimal.new("1.23"), :d}) ==
             "1.23"

    assert format_value({%Postgrex.Interval{secs: 0}, :i}) ==
             "0 seconds"

    assert format_value({%Postgrex.Interval{months: 2, days: 2, secs: 1, microsecs: 654_321}, :i}) ==
             "2 months, 2 days, 1.654321 seconds"
  end
end
