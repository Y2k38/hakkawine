defmodule Hakkawine.AuditsTest do
  use Hakkawine.DataCase

  alias Hakkawine.Audits

  describe "user_audit_logs" do
    alias Hakkawine.Audits.UserAuditLog

    import Hakkawine.AuditsFixtures

    @invalid_attrs %{user_id: nil}

    test "list_user_audit_logs/0 returns all user_audit_logs" do
      user_audit_log = user_audit_log_fixture()
      assert Audits.list_user_audit_logs() == [user_audit_log]
    end

    test "get_user_audit_log!/1 returns the user_audit_log with given id" do
      user_audit_log = user_audit_log_fixture()
      assert Audits.get_user_audit_log!(user_audit_log.id) == user_audit_log
    end

    test "create_user_audit_log/1 with valid data creates a user_audit_log" do
      valid_attrs = %{user_id: 42}

      assert {:ok, %UserAuditLog{} = user_audit_log} = Audits.create_user_audit_log(valid_attrs)
      assert user_audit_log.user_id == 42
    end

    test "create_user_audit_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Audits.create_user_audit_log(@invalid_attrs)
    end

    test "update_user_audit_log/2 with valid data updates the user_audit_log" do
      user_audit_log = user_audit_log_fixture()
      update_attrs = %{user_id: 43}

      assert {:ok, %UserAuditLog{} = user_audit_log} = Audits.update_user_audit_log(user_audit_log, update_attrs)
      assert user_audit_log.user_id == 43
    end

    test "update_user_audit_log/2 with invalid data returns error changeset" do
      user_audit_log = user_audit_log_fixture()
      assert {:error, %Ecto.Changeset{}} = Audits.update_user_audit_log(user_audit_log, @invalid_attrs)
      assert user_audit_log == Audits.get_user_audit_log!(user_audit_log.id)
    end

    test "delete_user_audit_log/1 deletes the user_audit_log" do
      user_audit_log = user_audit_log_fixture()
      assert {:ok, %UserAuditLog{}} = Audits.delete_user_audit_log(user_audit_log)
      assert_raise Ecto.NoResultsError, fn -> Audits.get_user_audit_log!(user_audit_log.id) end
    end

    test "change_user_audit_log/1 returns a user_audit_log changeset" do
      user_audit_log = user_audit_log_fixture()
      assert %Ecto.Changeset{} = Audits.change_user_audit_log(user_audit_log)
    end
  end
end
