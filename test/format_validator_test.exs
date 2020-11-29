defmodule QuenyaTest.FormatValidator do
  use ExUnit.Case
  alias Quenya.FormatValidator
  doctest FormatValidator

  test "format uuid should work as expected" do
    data = [
      {UUID.uuid1(), true},
      {UUID.uuid3(:dns, "my.domain.com", :default), true},
      {UUID.uuid4(), true},
      {"hello world", false}
    ]

    do_validate(data, "uuid")
  end

  test "format uri should work as expected" do
    data = [
      {"http://vk.com", true},
      {"http://semantic-ui.com/collections/menu.html", true},
      {"https://translate.yandex.ru/?text=poll&lang=en-ru", true},
      {"www.vk.com", false},
      {"abdeeej", false},
      {"http://vk", false}
    ]

    do_validate(data, "uri")
  end

  test "format image_uri should work as expected" do
    data = [
      {"https://images.google.com/test.jpg", true},
      {"https://source.unsplash.com/random", true},
      {"abdeeej", false},
      {"http://vk", false}
    ]

    do_validate(data, "image_uri")
  end

  defp do_validate(data, format) do
    Enum.each(data, fn {v, expected} ->
      assert FormatValidator.validate(format, v) == expected
    end)
  end
end
