package br.com.sigas.repositories;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import br.com.sigas.entities.Operacoes;

@Repository
public interface OperacoesRepository extends JpaRepository<Operacoes, Integer> {

        @Procedure(procedureName = "inserir_operacao")
        void inserirOperacao(
                        @Param("id_pessoa") Long idPessoa,
                        @Param("tipo_operacao") Character tipoOperacao,
                        @Param("data_operacao") LocalDate dataOperacao);

        @Query(value = "SELECT * FROM operacoes WHERE id_pessoa = :id_pessoa", nativeQuery = true)
        List<Operacoes> buscarOperacoesPorPessoa(@Param("id_pessoa") Long idPessoa);

        @Query(value = "SELECT * FROM operacoes WHERE id_operacao = :id_operacao", nativeQuery = true)
        Operacoes buscarOperacaoPorId(@Param("id_operacao") Integer idOperacao);

        @Procedure(procedureName = "atualizar_operacao")
        void atualizarOperacao(
                        @Param("id_operacao") Integer idOperacao,
                        @Param("id_pessoa") Long idPessoa,
                        @Param("tipo_operacao") Character tipoOperacao,
                        @Param("data_operacao") LocalDate dataOperacao);

        @Procedure(procedureName = "deletar_operacao")
        void deletarOperacao(@Param("id_operacao") Integer idOperacao);
}
