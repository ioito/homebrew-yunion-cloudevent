class YunionCloudevent < Formula
  desc "Yunion CloudEvent Controller Service"
  homepage "https://github.com/yunionio/onecloud.git"
  version_scheme 1
  head "https://github.com/yunionio/onecloud.git",
    :branch      => "master"
  
  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath

    (buildpath/"src/yunion.io/x/onecloud").install buildpath.children
    cd buildpath/"src/yunion.io/x/onecloud" do
      system "make", "GOOS=darwin", "cmd/cloudevent"
      bin.install "_output/bin/cloudevent"
      prefix.install_metafiles
    end

    (buildpath/"cloudevent.conf").write cloudevent_conf
    etc.install "cloudevent.conf"
  end

  def post_install
    (var/"log/cloudevent").mkpath
  end

  def cloudevent_conf; <<~EOS
  region = 'Yunion'
  address = '127.0.0.1'
  port = 7777
  auth_uri = 'https://127.0.0.1:35357/v3'
  admin_user = 'sysadmin'
  admin_password = 'sysadmin'
  admin_tenant_name = 'system'
  sql_connection = 'mysql+pymysql://root:password@127.0.0.1:3306/cloudevent?charset=utf8'
  enable_ssl = false
  rbac_debug = false
  EOS
  end

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>RunAtLoad</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/cloudevent</string>
        <string>--conf</string>
        <string>#{etc}/cloudevent.conf</string>
        <string>--auto-sync-table</string>
      </array>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/cloudevent/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/cloudevent/output.log</string>
    </dict>
    </plist>
  EOS
  end

  test do
    system "false"
  end
end
