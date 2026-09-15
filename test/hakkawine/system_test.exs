defmodule Hakkawine.SystemTest do
  use Hakkawine.DataCase

  alias Hakkawine.System

  describe "settings" do
    alias Hakkawine.System.Setting

    import Hakkawine.SystemFixtures

    @invalid_attrs %{value: nil, description: nil, key: nil, section: nil}

    test "list_settings/0 returns all settings" do
      setting = setting_fixture()
      assert System.list_settings() == [setting]
    end

    test "get_setting!/1 returns the setting with given id" do
      setting = setting_fixture()
      assert System.get_setting!(setting.id) == setting
    end

    test "create_setting/1 with valid data creates a setting" do
      valid_attrs = %{value: %{}, description: "some description", key: "some key", section: "some section"}

      assert {:ok, %Setting{} = setting} = System.create_setting(valid_attrs)
      assert setting.value == %{}
      assert setting.description == "some description"
      assert setting.key == "some key"
      assert setting.section == "some section"
    end

    test "create_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = System.create_setting(@invalid_attrs)
    end

    test "update_setting/2 with valid data updates the setting" do
      setting = setting_fixture()
      update_attrs = %{value: %{}, description: "some updated description", key: "some updated key", section: "some updated section"}

      assert {:ok, %Setting{} = setting} = System.update_setting(setting, update_attrs)
      assert setting.value == %{}
      assert setting.description == "some updated description"
      assert setting.key == "some updated key"
      assert setting.section == "some updated section"
    end

    test "update_setting/2 with invalid data returns error changeset" do
      setting = setting_fixture()
      assert {:error, %Ecto.Changeset{}} = System.update_setting(setting, @invalid_attrs)
      assert setting == System.get_setting!(setting.id)
    end

    test "delete_setting/1 deletes the setting" do
      setting = setting_fixture()
      assert {:ok, %Setting{}} = System.delete_setting(setting)
      assert_raise Ecto.NoResultsError, fn -> System.get_setting!(setting.id) end
    end

    test "change_setting/1 returns a setting changeset" do
      setting = setting_fixture()
      assert %Ecto.Changeset{} = System.change_setting(setting)
    end
  end
end
