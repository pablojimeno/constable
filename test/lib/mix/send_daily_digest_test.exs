defmodule Mix.Tasks.Constable.SendDailyDigestTest do
  use Constable.TestWithEcto, async: false
  use Bamboo.Test

  test "sends daily digest to users that want a daily digest" do
    daily_digest_user = create(:user, daily_digest: true)
    announcement = create(:announcement, user: daily_digest_user)
    create(:user, daily_digest: false)

    Mix.Tasks.Constable.SendDailyDigest.run(nil)

    assert_delivered_email Constable.Emails.daily_digest(
      [],
      [announcement],
      [daily_digest_user]
    )
  end
end
