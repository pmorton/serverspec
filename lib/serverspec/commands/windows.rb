require 'shellwords'
require 'base64'

module Serverspec
  module Commands
    class Windows < Base

      def wrap_powershell(cmd, encode = false)
        base_command = "powershell"
        if encode
          cmd = (cmd.chars.to_a.join("\x00").chomp)
          cmd << "\x00" unless cmd[-1].eql? "\x00"
          return base_command << " -encodedCommand #{Base64.strict_encode64(cmd.encode('ASCII-8BIT'))}"
        else
          return base_command << " -command \"#{cmd}\""
        end
      end

      # Exit normally if the condition is met
      def pipeline_count_exit_true(pipeline,operator,count)
        wrap_powershell("if( (#{pipeline}).count #{operator} #{count}) { exit 0 } else { exit 1 }")
      end

      alias :check_mounted :not_implemented #Path
      alias :check_installed :not_implemented #Package
      alias :check_running_under_supervisor :not_implemented
      alias :check_mode :not_implemented #file #mode
      alias :check_owner :not_implemented #file owner
      alias :check_grouped :not_implemented #fie #group
      alias :check_gid :not_implemented #group gid
      alias :check_uid :not_implemented #user uid
      alias :check_login_shell :not_implemented #user path_to_shell
      alias :check_home_directory :not_implemented #user, path_to_home
      alias :check_authorized_key :not_implemented #user key
      alias :check_iptables_rules :not_implemented #rule, table=nil, chain=nil
      alias :get_mode :not_implemented #file
      alias :check_ipfilter_rule :not_implemented #rule
      alias :check_ipnat_rule :not_implemented #rule
      alias :check_svcprop :not_implemented #svc, property, value
      alias :check_svcprops :not_implemented #svc, property
      alias :check_selinux :not_implemented #mode
      alias :check_link :not_implemented #link, #target
      alias :check_file_contain_within :not_implemented # file, expected_pattern, from=nil, to=nil
      alias :check_cron_entry :not_implemented #user entry

      def check_reachable host, port, proto, timeout
        if port.nil?
          "ping -n 3 #{escape(host)} -w #{escape(timeout)}"
        else
          wrap_powershell "$socket = New-Object net.sockets.tcpclient('#{host}',#{port}); if ($socket.Connected) { exit 0 } else { exit 1 }"
        end
      end

      def check_resolvable name, type
        type = 'dns' if type.nil? || type.empty?
        case type.downcase.to_sym
        when :hosts
          pipeline_count_exit_true("cat \"$ENV:SystemRoot\\System32\\Drivers\\etc\\hosts\"|where {!$_.StartsWith('#')} | where {$_ -match '#{escape(name)}'}", "-ne", 0)
        when :dns
           wrap_powershell( "[System.Net.DNS]::GetHostAddresses('#{escape(name)}')")
        else
          raise NotImplementedError.new
        end
      end
      #Fix Me
      def check_file file
        wrap_powershell("if ( (Get-Item ('#{file}')).PSIsContainer ) { exit 1 }")
      end
      #Fix Me
      def check_directory directory
        wrap_powershell("if ( !(Get-Item ('#{directory}')).PSIsContainer ) { exit 1 }")
      end

      def check_user user
        "net user #{escape(user)}"
      end

      def check_group group
        "net localgroup #{escape(group)}"
      end

      def check_listening port
        pipeline_count_exit_true("netstat -a | where { $_ -match 'LISTENING'} | where { $_ -match ':#{port}' }", "-ne", 0)
      end

      def check_running service
        pipeline_count_exit_true("Get-Service \"#{service}\" | where { $_.Status -eq 'Running' }", '-ne', 0)
      end

      def check_enabled service
        wrap_powershell "$Filter = { Name='#{service}' AND StartMode='Auto' }.ToString() ; if( ( Get-WmiObject Win32_Service -Filter $Filter).count -ne 0) { exit 0 } else { exit 1 }"
      end

      def check_file_contain file, expected_pattern
        pipeline_count_exit_true("cat '#{file}' | Where { $_ -match '#{expected_pattern}' }", '-ne', 0)
      end

      def check_installed_by_gem name
        gem_name = "^#{name} "
        pipeline_count_exit_true("gem list --local|where { $_ -match '#{gem_name}' }", '-ne', 0)
      end

      def check_belonging_group user, group
        pipeline_count_exit_true("([ADSI]'WinNT://Localhost/#{group},group').psbase.Invoke('Members') | % { Write-Output $_.GetType().InvokeMember('Name', 'GetProperty', $null, $_, $null) }|where { $_ -imatch '#{user}' }", "-ne", 0)
      end

    end
  end
end
