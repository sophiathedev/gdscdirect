defmodule GdscDirect.Database do
  # for elixir assertion
  use ExUnit.Case

  @moduledoc "Sqlite3 database wrapper for Exqlite"
  alias Exqlite.Sqlite3
  # get the database name from config
  @database_name Application.compile_env!(:gdsc_direct, [:global_conf, :db_name])

  defp open_db(db_name \\ @database_name) do
    Sqlite3.open(db_name)
  end

  ## UTILITY ######################################################################################
  @doc "Get the first row from select result"
  @spec first_row(list()) :: list() | :end_of_query
  def first_row(row) do
    row |> Enum.at(0)
  end

  #################################################################################################

  ## SELECT QUERY SECTION #########################################################################

  @doc "Select function for using select query in database"
  @spec select(any()) :: list()
  def select(table, field \\ [~c"*"], condition \\ nil) do
    # preprocessor when table and field element is atom convert it into string
    table = if is_atom(table), do: Atom.to_string(table), else: table
    field = field |> Enum.map(&a_to_s/1)
    # open the database
    {:ok, conn} = open_db()

    # setup the query string
    selection_field = field |> Enum.join(",")
    selection_query = "SELECT #{selection_field} FROM #{table}"
    selection_query = selection_query <> if condition != nil, do: " #{condition}", else: ""

    # prepare the query in exqlite
    {:ok, query_statement} = conn |> Sqlite3.prepare(selection_query)

    # return selection query like in a list
    parse_select_query(conn, query_statement)
  end

  # parse selection query into result
  defp parse_select_query(conn, statement) do
    case Sqlite3.step(conn, statement) do
      {:row, row} -> [row | parse_select_query(conn, statement)]
      :done -> [:end_of_query]
      _ -> []
    end
  end

  #################################################################################################

  ## UPDATE QUERY SECTION #########################################################################
  @doc "Wrapper function for update query in sqlite3"
  @spec update(atom() | String.t(), [atom() | String.t()], [atom() | String.t()], String.t()) ::
          :done
  def update(table, field, value, condition \\ nil) do
    # preprocessor when table and field element is atom, convert it into string
    table = if is_atom(table), do: Atom.to_string(table), else: table
    field = field |> Enum.map(&a_to_s/1)

    # open the database
    {:ok, conn} = open_db()

    # length of field required for length of value
    assert length(field) == length(value)

    # setup the query string
    # before setup fully we setup the left-right value for update
    update_set_section =
      0..(length(field) - 1)
      |> Enum.reduce([], fn index, default ->
        ["#{Enum.at(field, index)} = #{Enum.at(value, index)}" | default]
      end)
      |> Enum.join(", ")

    update_query = "UPDATE #{table} SET #{update_set_section}"
    # concat the condition
    update_query = update_query <> if condition != nil, do: " #{condition}", else: ""

    # prepare statement
    {:ok, statement} = Sqlite3.prepare(conn, update_query)
    :done = Sqlite3.step(conn, statement)
    # local return that query was completed
    {:ok}
  end

  #################################################################################################

  ## INSERT QUERY SECTION #########################################################################

  @doc "Wrapper function for insert query table sqlite3"
  @spec insert(atom() | String.t(), list(atom() | String.t()), list(any())) :: :done
  def insert(table, field, values) do
    # preprocessor when table and field element is atom, convert it into string
    table = if is_atom(table), do: a_to_s(table), else: table
    field = field |> Enum.map(&a_to_s/1)

    # open the database
    {:ok, conn} = open_db()

    # length of field and length of values need to equal
    assert length(field) == length(values)

    field_section = field |> Enum.join(", ")
    value_section = values |> Enum.join(", ")

    insert_query = "INSERT INTO #{table} (#{field_section}) VALUES(#{value_section})"
    {:ok, statement} = Sqlite3.prepare(conn, insert_query)
    :done = Sqlite3.step(conn, statement)
  end

  #################################################################################################

  ## INSERT QUERY SECTION #########################################################################

  @doc "Wrapper function for delete query in sqlite3"
  @spec delete(atom() | String.t()) :: :done
  def delete(table, condition \\ nil) do
    # preprocessor when table ios atom, convert it into string
    table = a_to_s(table)

    # open the database
    {:ok, conn} = open_db()

    delete_query = "DELETE FROM #{table} " <> if condition == nil, do: "", else: " #{condition}"
    {:ok, statement} = Sqlite3.prepare(conn, delete_query)
    :done = Sqlite3.step(conn, statement)
  end

  #################################################################################################

  # some stupid util stuff
  # function for convert atom to string
  defp a_to_s(s), do: if(is_atom(s), do: Atom.to_string(s), else: s)
end
