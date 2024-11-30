package br.com.sigas.repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import br.com.sigas.entities.PessoasJuridicas;

@Repository
public interface PessoasJuridicasRepository extends JpaRepository<PessoasJuridicas, Long> {

        @Query("SELECT p FROM PessoasJuridicas p WHERE p.cnpj = :cnpj")
        Optional<PessoasJuridicas> buscaPorCnpj(@Param("cnpj") String cnpj);

        @Query("SELECT p FROM PessoasJuridicas p WHERE p.cnpj LIKE CONCAT('%', :cnpj, '%')")
        List<PessoasJuridicas> buscarPorTrechoCnpj(@Param("cnpj") String cnpj);

        @Query("SELECT p FROM PessoasJuridicas p WHERE p.id_pessoa = :id")
        Optional<PessoasJuridicas> buscaPessoaJuridicaPorId(@Param("id") long id);

        @Query("SELECT p FROM PessoasJuridicas p WHERE LOWER(p.nome_pessoa) LIKE LOWER(CONCAT('%', :nome, '%'))")
        List<PessoasJuridicas> buscarPessoaJuridicaPorNome(@Param("nome") String nome);

        @Query("SELECT p FROM PessoasJuridicas p WHERE LOWER(p.razao_social) LIKE LOWER(CONCAT('%', :razao_social, '%'))")
        List<PessoasJuridicas> buscarPorRazaoSocial(@Param("razao_social") String razaoSocial);

        @Query("SELECT p FROM PessoasJuridicas p WHERE LOWER(p.email_pessoa) LIKE LOWER(CONCAT('%', :email, '%'))")
        List<PessoasJuridicas> buscarPorEmail(@Param("email") String email);

        @Procedure(procedureName = "inserir_pessoa_juridica")
        void inserirPessoaJuridica(
                        @Param("id_pessoa") Long idPessoa,
                        @Param("cnpj") String cnpj,
                        @Param("razao_social") String razaoSocial);

        @Procedure(procedureName = "atualizar_pessoa_juridica")
        void atualizarPessoaJuridica(
                        @Param("id_pessoa") Integer idPessoa,
                        @Param("nome_pessoa") String nomePessoa,
                        @Param("email_pessoa") String emailPessoa,
                        @Param("endereco_pessoa") String enderecoPessoa,
                        @Param("tel1_pessoa") String tel1Pessoa,
                        @Param("tel2_pessoa") String tel2Pessoa,
                        @Param("cnpj") String cnpj,
                        @Param("razao_social") String razaoSocial);

        @Procedure(procedureName = "deletar_pessoa_juridica")
        void deletarPessoaJuridica(@Param("id_pessoa") Long idPessoa);

}
